package s3

import (
	"bytes"
	"context"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	observerpb "github.com/cilium/cilium/api/v1/observer"
	"go.uber.org/zap"
)

type S3Config struct {
	Region          string
	Endpoint        string
	Bucket          string
	Prefix          string
	AccessKeyID     string
	SecretAccessKey string
}

type Sender struct {
	logger     *zap.Logger
	senderChan chan observerpb.GetFlowsResponse
	s3Config   S3Config
	awsConfig  *aws.Config
}

func NewSender(senderChan *chan observerpb.GetFlowsResponse, s3Config S3Config, awsConfig *aws.Config, logger *zap.Logger) *Sender {
	return &Sender{
		senderChan: *senderChan,
		s3Config:   s3Config,
		logger:     logger.Named("sender"),
		awsConfig:  awsConfig,
	}
}

func (s *Sender) Worker(ctx context.Context) error {
	cfg := &aws.Config{
		Region:      aws.String(s.s3Config.Region),
		Endpoint:    aws.String(s.s3Config.Endpoint),
		Credentials: credentials.NewStaticCredentials(s.s3Config.AccessKeyID, s.s3Config.SecretAccessKey, ""),
	}
	s3Session, err := session.NewSession(cfg, s.awsConfig)
	if err != nil {
		return err
	}
	s3Client := s3.New(s3Session)

	s.logger.Info("Sender started")

	for {
		select {
		case flow := <-s.senderChan:
			j, err := flow.MarshalJSON()
			if err != nil {
				return err
			}

			t := time.Now()
			key := fmt.Sprintf("%s/%s.json", s.s3Config.Prefix, t.UTC().Format(time.RFC3339Nano))

			_, err = s3Client.PutObject(&s3.PutObjectInput{
				Bucket: aws.String(s.s3Config.Bucket),
				Key:    aws.String(key),
				Body:   bytes.NewReader(j),
			})
			if err != nil {
				return err
			}
			s.logger.Info("Event sent", zap.String("key", key))
		case <-ctx.Done():
			s.logger.Info("Context done, exiting...")
			return nil
		}
	}
}
