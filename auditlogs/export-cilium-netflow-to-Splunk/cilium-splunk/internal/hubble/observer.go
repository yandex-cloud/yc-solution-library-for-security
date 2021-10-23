package hubble

import (
	"context"
	"time"

	observerpb "github.com/cilium/cilium/api/v1/observer"
	"go.uber.org/zap"
	"google.golang.org/grpc"
)

type Observer struct {
	logger     *zap.Logger
	url        string
	senderChan chan observerpb.GetFlowsResponse
}

func NewObserver(senderChan *chan observerpb.GetFlowsResponse, url string, logger *zap.Logger) *Observer {
	return &Observer{
		logger:     logger.Named("observer"),
		url:        url,
		senderChan: *senderChan,
	}
}

func (o *Observer) Start(ctx context.Context) error {
	dialCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	conn, err := grpc.DialContext(dialCtx, o.url, grpc.WithInsecure(), grpc.WithBlock())
	if err != nil {
		return err
	}
	defer conn.Close()

	client := observerpb.NewObserverClient(conn)

	flows, err := client.GetFlows(ctx, &observerpb.GetFlowsRequest{
		Follow: true,
	})
	if err != nil {
		return err
	}

	o.logger.Info("Observer started")
	for {
		flow, err := flows.Recv()
		if err != nil {
			return err
		}
		o.logger.Debug("Flow received", zap.Any("flow", flow))
		o.senderChan <- *flow
	}
}
