require 'omniauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :github,
    ENV.fetch('GITHUB_OAUTH_CLIENT_ID'),
    ENV.fetch('GITHUB_OAUTH_SECRET')
end

