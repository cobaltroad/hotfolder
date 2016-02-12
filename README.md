# Hotfolder

The hotfolder gem is a plugin that provides a variety of build-in methods to automatically detect new files in a hotfolder and upload them into Runner.

# Usage

The entry point for this gem is a YAML file that loads configuration variables and classes, including the main hotfolder class itself.

Here is the `scripts/hotfolder.rb` script in Granite:

    require_relative '../init'

    root = File.dirname(__FILE__)
    glob = File.join(root, "../config/hotfolder", "**", "*.yml")
    Dir.glob(glob).each do |file|
      hash = YAML.load_file(file)
      config = hash[ENV['granite_env']].with_indifferent_access
      require config['class_name'].underscore
      require config['metadata_class_name'].underscore
      if config['ready_class_name']
        require config['ready_class_name'].underscore
      end
      klass = config['class_name'].constantize

      hotfolder = klass.config(config).new
      hotfolder.consume!
    end

What this script is doing is reading every YAML file in the config/hotfolder directory, keying into a particular environment, and then using that config hash to new up an instance of a hotfolder class.

Here is a basic hotfolder class used in Granite, which is configured to post to Runner as a "runner" ingest type:

    require 'hotfolder'

    class AsperaRunnerHotfolder
      include Hotfolder

      hotfolder_ingest_type Nummer::IngestType::RUNNER
      hotfolder_logger      GraniteLogger.logger, :info
      # hotfolder_access_method :aspera
    end

The mixin line `include Hotfolder` is what provides the class methods above as well as the `consume!` method in the script before it.

### Configuration File Keys

* `name`

* `aspera_username`

* `aspera_password`

* `aspera_endpoint`

* `source_file_path`

* `file_pickup_delay_hours`

* `runner_path_id`

* `files_per_batch`

* `metadata_class` See section below.

* `ready_class` (OPTIONAL) See section below.

### Class Methods

* `hotfolder_ingest_type` This sets the ingest type for all files found within this hotfolder.
It is set in the class as opposed to the configuration file so that a Ruby object can be passed in.
The ingest type must be a valid value in `Nummer::IngestType`


* `hotfolder_logger` This configures the logging mechanism for the class.

### Metadata Class

The metadata class key allows the system to use common hotfolder infrastructure (as denoted by the ingest type) but use a different method of retrieving metadata.
There are two approaches to writing this class.

One way is to simply write a class whose `initialize` accepts an instance of `Hotfolder::Hotfile` and sets `@gpms_ids`, `@name`, and `@folder_ids`.
The class also has to define a `runner_object` method.

Here is an example of the first approach:

    class BasicMetadata
      attr_accessor :source_folder

      def initialize(file)
        @name = file.basename
        @source_folder = file.path.split('/').last
      end

      def runner_object
        {
          name: @name,
          folder_ids: [14285]
        }
      end
    end

The other way is to use the base `Hotfolder::Hotmetadata` class as a parent.
The only responsibility for the child class is to define an `on_initialize(file)` that takes an instance of `Hotfolder::Hotfile` as a parameter.
Because the `runner_object` is already defined in the parent, the child class just has to set the instance variables `@gpms_ids` and `@folder_ids`.
As this gem matures, more base functionality might be packed into this base class, which makes this method a bit more future-proof.
That's the trade-off between this and the first method.

Here is an example of this second approach:

    class GameshowMetadata < Hotfolder::Hotmetadata
      attr_accessor :slug
      attr_accessor :revision

      def on_initialize(file)
        filename = file.basename
        series, show_number, rev, rev_number = filename_regex_match(filename)

        @slug           = "#{series}#{show_number}"
        revision_number = rev_number.blank? ? 1 : rev_number.to_i
        @revision       = rev.blank?        ? 0 : revision_number

        mapped_series = MAPPING[series]
        if mapped_series
          mapped_show_number = "#{mapped_series[:show_number_prefix]}#{show_number}"

          @gpms_ids   = [get_show_gpms_id(mapped_series[:gpms_id], mapped_show_number)]
          @folder_ids = [get_folder_id(mapped_series[:folder_business_key])]
        end
      end

      # other logic snipped out
    end

### Ready Class

This is an optional parameter allowing the system to have a different mechanism other than the default.

By default:

    module Hotfolder
      module GetReadyFilesCommand
        extend self

        def execute(new_hotfiles, delay_in_hours, limit)
          ready = new_hotfiles.select do |hotfile|
            hotfile.ready? delay_in_hours
          end
          Hotfolder.log "Ready files: #{ready.map(&:basename)}"
          ready.first(limit)
        end
      end
    end

A custom ready class should create an `execute(files, delay, limit)` method that outputs an array of files.

# Future Considerations

Eventually, reading the hotfolder itself could be done by something other than Aspera.
