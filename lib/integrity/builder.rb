module Integrity
  class Builder
    def self.build(b)
      new(b).build
    end

    def initialize(build)
      @build  = build
      @status = false
      @output = ""
    end

    def build
      start
      run
      complete
    end

    def start
      Integrity.log "Started building #{@build.project.uri} at #{commit}"

      repo.checkout

      metadata = repo.metadata

      @build.update(
        :started_at => Time.now,
        :commit     => {
          :identifier   => metadata["id"],
          :message      => metadata["message"],
          :author       => metadata["author"],
          :committed_at => metadata["timestamp"]
        }
      )
    end

    def complete
      Integrity.log "Build #{commit} exited with #{@status} got:\n #{@output}"

      @build.update!(
        :completed_at => Time.now,
        :successful   => @status,
        :output       => @output
      )

      @build.project.enabled_notifiers.each { |n| n.notify_of_build(@build) }
    end

    def run
      # HACK: gem bundler sets the RUBYOPT env variable which jacks with projects own gem management so unset in command
      cmd = "(#{bundler_env_fix} && cd #{repo.directory} && #{@build.project.command} 2>&1)"
      @output = ''
      IO.popen(cmd, "r") do |io|
        # incremental update of status
        io.each do |line|
          @output += line
          @build.update!(
            :output       => @output
          )
        end
      end
      @status = $?.success?
    end

    def bundler_env_fix
      # HACK: gem bundler sets the RUBYOPT env variable which jacks with projects own gem management so unset in command
      file = File.expand_path('vendor/gems/environment.rb')
      dir = File.dirname(file)

      path = ENV['PATH'].gsub("#{dir}/../../bin:", '')
      rubyopt = ENV['RUBYOPT'].gsub("-r#{file}", '')

      "RUBYOPT=#{rubyopt} && PATH=#{path}"
    end

    def repo
      @repo ||= Repository.new(@build.project.uri, @build.project.branch, commit)
    end

    def commit
      @build.commit.identifier
    end

  end
end
