namespace :secrets do
  desc 'Generate the secrets.yml file with a unique secret key'
  task :setup do
    require 'securerandom'

    # TODO: make rake use a root project directory rather than these relative ones
    path = File.expand_path('../../../config/secrets.yml', __FILE__)

    if File.exist?(path)
      puts 'File secrets.yml already exists'
      abort
    end

    secret_key = SecureRandom.hex(16)

    File.open(path, 'w') do |file|
      file.write <<-EOF
secret_key: #{secret_key}
EOF
    end
  end
end
