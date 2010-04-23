module Integrity
  module Helpers
    module Json

      def build_poll_json(build)
        {
            :status => build.status,
            :build_message => build.human_status,
            :commit_message => build.commit.message,
            :who => "by: #{build.commit.author.name}",
            :when => pretty_date( build.commit.committed_at),
            :what => "commit: #{build.commit.identifier}",
            :output => bash_color_codes(h(build.output))
        }.to_json
      end

    end
  end
end