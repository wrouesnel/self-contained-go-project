package main

import (
	"context"
	"os"
	"os/signal"
	"syscall"

	"github.com/wrouesnel/self-contained-go-project/pkg/config"
	"github.com/wrouesnel/self-contained-go-project/version"
	"go.uber.org/zap/zapcore"

	"github.com/alecthomas/kong"
	"go.uber.org/zap"
)

//nolint:gochecknoglobals
var CLI struct {
	Version   kong.VersionFlag `help:"Show version number"`
	LogLevel  string           `help:"Logging Level" enum:"debug,info,warning,error" default:"info"`
	LogFormat string           `help:"Logging format" enum:"console,json" default:"console"`

	ConfigFile string `help:"File to load poller config from" default:"self-contained-go-project.yml"`
}

func main() {
	os.Exit(cmdMain(os.Args[1:]))
}

func cmdMain(args []string) int {
	vars := kong.Vars{}
	vars["version"] = version.Version
	kongParser, err := kong.New(&CLI, vars)
	if err != nil {
		panic(err)
	}

	_, err = kongParser.Parse(args)
	kongParser.FatalIfErrorf(err)

	// Configure logging
	logConfig := zap.NewProductionConfig()
	logConfig.Encoding = CLI.LogFormat
	var logLevel zapcore.Level
	if err := logLevel.UnmarshalText([]byte(CLI.LogLevel)); err != nil {
		panic(err)
	}
	logConfig.Level = zap.NewAtomicLevelAt(logLevel)

	log, err := logConfig.Build()
	if err != nil {
		panic(err)
	}

	// Replace the global logger to enable logging
	zap.ReplaceGlobals(log)

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
	ctx, cancelFn := context.WithCancel(context.Background())
	go func() {
		sig := <-sigCh
		log.Info("Caught signal - exiting", zap.String("signal", sig.String()))
		cancelFn()
	}()

	appLog := log.With(zap.String("config_file", CLI.ConfigFile))

	cfg, err := config.LoadFromFile(CLI.ConfigFile)
	if err != nil {
		log.Error("Could not parse configuration file:", zap.Error(err))
		return 1
	}

	return realMain(ctx, appLog, cfg)
}

func realMain(ctx context.Context, l *zap.Logger, cfg *config.Config) int {
	if cfg == nil {
		l.Error("No config specified - shutting down")
		return 1
	}

}
