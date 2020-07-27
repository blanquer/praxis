module Praxis
  module Mapper
    class ReadOnlyModel
      MAPPING = {} # From model classes to our readonly model classes
      require 'digest'
      def self.for(model_klass)
        our_model_class = MAPPING[model_klass]
        return our_model_class if our_model_class
        # Create the class for it
        klass = Class.new do
          attr_reader :_resource # To make rendering happy
          def initialize( object, selector)
            @object = object
            @selector = selector
            @_resource = selector.resource.new(self)
          end

          def mymd5(md5 = Digest::MD5.new)
            md5.update(@object['id'].to_s + ':' + @object['updated_at'].to_i.to_s) # TODO! to_i/to_s? ...
            @selector.tracks.sort.each do |name,spec|
              val = self.send(name)
              if val.is_a? Array
                val.map{|i| i.mymd5(md5)}
              else
                val.mymd5(md5)
              end
            end
            md5
          end

          # Define a getter for each field
          attributes = model_klass.columns.map{|c| c.name.to_s}
          attributes.each do |name|
            # puts "Defining attribute #{name} for #{model_klass.name}"
            module_eval <<-ACCESSOR_RUBY, __FILE__, __LINE__ + 1
            def #{name}
              # TODO memoize
              @object.fetch("#{name}".freeze) do
                raise "Attribute #{name} not loaded! for \#\{@selector.resource.model\}: \#\{@object\}" unless @object.key?("#{name}.freeze")
              end
            end
            ACCESSOR_RUBY
          end
          # Define a getter for each association
          model_klass.reflect_on_all_associations.map{|a| a.name.to_s}.each do |name|
            # puts "Defining association #{name} for #{model_klass.name}"
            symname = name.to_sym
            module_eval <<-ASSOC_RUBY, __FILE__, __LINE__ + 1
            def #{name}
              # TODO memoize
              result = @object.fetch("#{name}".freeze) do
                # Associations won't even be there if there was not data associated...
                # So we need to know if we asked for it or not to know if it was loaded
                raise "Not loaded!" unless @selector.tracks.keys.include?(#{symname.inspect})
              end
              return nil if result.nil?

              track = @selector.tracks[#{symname.inspect}]
              track_model = track.resource.model
              # TODO recursive! ... detect it.
              # HACK, looking at the result being an array is not the right way to see if we want a collection.
              # We should look at the type of association instead
              if result.is_a? Array
                result.map{|item| Praxis::Mapper::ReadOnlyModel.for(track_model).new(item, track)}
              else
                Praxis::Mapper::ReadOnlyModel.for(track_model).new(result, track)
              end
            end
            ASSOC_RUBY
          end

          # def self.name
          #   "RO::#{model_klass}"
          # end
        end
        MAPPING[model_klass] = klass
      end

      # def initialize( object, selector)
      #     # selector:
      #     # => #<Praxis::Mapper::SelectorGeneratorNode:0x00007fb069cc2330
      #     # @resource=Im::V1::Resources::Contact,
      #     # @select=#<Set: {:id, :company_name, :first_name, :last_name, :preferred_name, :salutation, :marketing, :include_in_fundraising, :details}>,
      #     # @select_star=false,
      #     # @tracks=
      #     #  {:addresses=>
      #     #    #<Praxis::Mapper::SelectorGeneratorNode:0x00007fb069ca3b60
      #     #     @resource=Im::V1::Resources::Address,
      #     #     @select=#<Set: {:id, :street1, :street2, :pobox, :city, :state, :postal_code, :country_code, :label, :contact_id}>,
      #     #     @select_star=false,
      #     #     @tracks={}>,
      #     #   :emails=>
      #     #    #<Praxis::Mapper::SelectorGeneratorNode:0x00007fb069c98440
      #     #     @resource=Im::V1::Resources::ContactEmail,
      #     #     @select=#<Set: {:email, :contact_id}>,
      #     #     @select_star=false,
      #     #     @tracks={}>,
      #     #   :phones=>
      #     #    #<Praxis::Mapper::SelectorGeneratorNode:0x00007fb069c91000
      #     #     @resource=Im::V1::Resources::ContactPhone,
      #     #     @select=#<Set: {:phone, :label, :contact_id}>,
      #     #     @select_star=false,
      #     #     @tracks={}>}>
      #   @attributes = selector.select
      #   @resource = selector.resource
      #   @model = selector.resource.model
      #   @associations = selector.tracks.each_with_object({}) do |(name,spec),hash|
      #     hash[name] = self.class.new(object[name], spec)
      #   end
      # end
    end
  end
end