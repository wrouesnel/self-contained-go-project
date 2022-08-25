package config

// Config is the main application configuration structure.
type Config struct {
	ConfigKey string `mapstructure:"config_key,omitempty"`
}
