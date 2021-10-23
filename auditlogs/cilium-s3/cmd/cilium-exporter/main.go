package main

import (
	"cilium-splunk/internal/hubble"
	"cilium-splunk/internal/s3"
	"context"
	"flag"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	observerpb "github.com/cilium/cilium/api/v1/observer"
	"github.com/heetch/confita"
	"github.com/heetch/confita/backend/env"
	"github.com/heetch/confita/backend/file"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"golang.org/x/sync/errgroup"
)

type S3Config struct {
	Region          string `config:"S3_REGION,backend=env"`
	Endpoint        string `config:"S3_ENDPOINT,backend=env"`
	Bucket          string `config:"S3_BUCKET,backend=env"`
	Prefix          string `config:"S3_PREFIX,backend=env"`
	AccessKeyID     string `config:"S3_ACCESS_KEY_ID,backend=env" yaml:"access-key-id"`
	SecretAccessKey string `config:"S3_SECRET_ACCESS_KEY,backend=env" yaml:"secret-access-key"`
}

type Config struct {
	//Old string
	// HubbleRelayUrl string   `config:"hubble-relay-url,required" yaml:"hubble-relay-url"`
	//Есть сомнения, что так заработает (надо сделать чтобы через env)
	HubbleRelayUrl string   `config:"hubble-relay-url,required,backend=env"`
	S3             S3Config `config:"s3"`
}

var workerPoolSize = 1

var cfg = &Config{
	S3: S3Config{
		Region:   "ru-central1",
		Endpoint: "https://storage.yandexcloud.net",
	},
	HubbleRelayUrl: "hubble-relay.kube-system.svc.cluster.local:80",
}

var logger *zap.Logger
var debug bool

func init() {
	configPath := flag.String("config", "config.yaml", "Path to config file")
	flag.BoolVar(&debug, "debug", false, "Debug logger")
	flag.Parse()

	var level zapcore.Level = zapcore.InfoLevel
	if debug {
		level = zapcore.DebugLevel
	}

	logger = zap.New(zapcore.NewCore(
		zapcore.NewJSONEncoder(zap.NewProductionEncoderConfig()),
		zapcore.Lock(os.Stdout),
		zap.NewAtomicLevelAt(level),
	))

	err := confita.NewLoader(
		file.NewOptionalBackend(*configPath),
		env.NewBackend(),
	).Load(context.Background(), cfg)
	if err != nil {
		logger.Fatal(err.Error())
	}
	logger.Debug("Config loaded", zap.Any("config", cfg))
}

func main() {
	defer logger.Sync()

	ctx, done := context.WithCancel(context.Background())
	g, gctx := errgroup.WithContext(ctx)

	g.Go(func() error {
		signalChannel := make(chan os.Signal, 1)
		signal.Notify(signalChannel, os.Interrupt, syscall.SIGTERM)

		select {
		case sig := <-signalChannel:
			logger.Info("Received signal", zap.Any("signal", sig))
			done()
			time.AfterFunc(3*time.Second, func() {
				logger.Sync()
				logger.Fatal("Exit deadline exeeded")
			})
		case <-gctx.Done():
			logger.Info("Closing signal goroutine")
			return gctx.Err()
		}

		return nil
	})

	senderChan := make(chan observerpb.GetFlowsResponse)
	observer := hubble.NewObserver(&senderChan, cfg.HubbleRelayUrl, logger)

	awsConfig := aws.NewConfig()
	if debug {
		awsConfig.WithLogLevel(aws.LogDebug)
	}
	sender := s3.NewSender(&senderChan, s3.S3Config{
		Region:          cfg.S3.Region,
		Endpoint:        cfg.S3.Endpoint,
		Bucket:          cfg.S3.Bucket,
		Prefix:          cfg.S3.Prefix,
		AccessKeyID:     cfg.S3.AccessKeyID,
		SecretAccessKey: cfg.S3.SecretAccessKey,
	}, awsConfig, logger)

	g.Go(func() error {
		gctx := gctx
		return observer.Start(gctx)
	})
	for i := 0; i < workerPoolSize; i++ {
		g.Go(func() error {
			gctx := gctx
			return sender.Worker(gctx)
		})
	}

	if err := g.Wait(); err == nil || err == context.Canceled {
		logger.Info("Finished clean")
	} else {
		logger.Error("Error while waiting for goroutines", zap.Error(err))
	}
}
