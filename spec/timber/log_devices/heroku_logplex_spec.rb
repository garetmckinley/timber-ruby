require "spec_helper"

describe Timber::LogDevices::HerokuLogplex do
  let(:log_device) { described_class.new }

  describe ".write" do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
    let(:valid_message) { "this is a message \e[30m[timber.io] server.hostname=computer-name.domain.com server._dt=2016-09-01T12:00:00.000000Z server._version=1 server._index=0 _version=1\e[0m\n" }

    before(:each) do
      server_context = Timber::CurrentContext.get(Timber::Contexts::Server)
      allow(server_context).to receive(:_dt).and_return(time)
    end

    it "writes a proper logfmt line" do
      expect(STDOUT).to receive(:write).with(valid_message)
      # Notice we do not have dt for the log line since Heroku provides this
      log_device.write("this is a message\n")
    end

    context "with a heroku context" do
      around(:each) do |example|
        heroku = Timber::Contexts::Servers::HerokuSpecific.new("web.1")
        Timber::CurrentContext.add(heroku) { example.run }
      end

      # No need for the heroku context since logplex includes that data by default
      it "does not include the heroku context" do
        expect(STDOUT).to receive(:write).with(valid_message)
        # Notice we do not have dt for the log line since Heroku provides this
        log_device.write("this is a message\n")
      end
    end
  end
end