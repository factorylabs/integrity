module Integrity
  class Build
    include DataMapper::Resource

    property :id,           Serial
    property :project_id,   Integer   # TODO :nullable => false
    property :output,       Text,     :default => "", :lazy => false,
      :length => 1048576
    property :successful,   Boolean,  :default => false
    property :started_at,   DateTime
    property :completed_at, DateTime

    timestamps :at

    belongs_to :project
    has 1,     :commit

    before :destroy do commit.destroy! end
    before :create do cleanup_builds end

    def self.pending
      all(:started_at => nil)
    end

    def pending?
      started_at.nil?
    end

    def building?
      ! started_at.nil? && completed_at.nil?
    end

    def failed?
      !successful?
    end

    def status
      case
      when pending?    then :pending
      when building?   then :building
      when successful? then :success
      when failed?     then :failed
      end
    end

    def human_status
      case status
      when :success  then "Built #{commit.short_identifier} successfully"
      when :failed   then "Built #{commit.short_identifier} and failed"
      when :pending  then "This commit hasn't been built yet"
      when :building then "#{commit.short_identifier} is building"
      end
    end

    def cleanup_builds
      `find #{Integrity.directory.join('builds', repository_path)} -maxdepth 1 -type d -mtime +#{Integrity.keep_build_days} | xargs rm -rf`
      project.builds.all(:created_at.lte => (Time.now - 60 * 60 * 24 * Integrity.keep_build_days)).each do |build|
        build.destroy
      end
    end

    def repository_path
     "#{project.uri}-#{project.branch}".
      gsub(/[^\w_ \-]+/i, "-").
      gsub(/[ \-]+/i, "-").
      gsub(/^\-|\-$/i, "")
    end
  end
end
