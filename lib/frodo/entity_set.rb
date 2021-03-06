module Frodo
  # This class represents a set of entities within an Frodo service. It is
  # instantiated whenever an Frodo::Service is asked for an EntitySet via the
  # Frodo::Service#[] method call. It also provides Enumerable behavior so that
  # you can interact with the entities within a set in a very comfortable way.
  #
  # This class also implements a query interface for finding certain entities
  # based on query criteria or limiting the result set returned by the set. This
  # functionality is implemented through transparent proxy objects.
  class EntitySet
    include Enumerable

    # The name of the EntitySet
    attr_reader :name
    # The Entity type for the EntitySet
    attr_reader :type
    # The Frodo::Service's namespace
    attr_reader :namespace
    # The Frodo::Service's identifiable name
    attr_reader :service_name
    # The EntitySet's container name
    attr_reader :container

    # Sets up the EntitySet to permit querying for the resources in the set.
    #
    # @param options [Hash] the options to setup the EntitySet
    # @return [Frodo::EntitySet] an instance of the EntitySet
    def initialize(options = {})
      @name         = options[:name]
      @type         = options[:type]
      @namespace    = options[:namespace]
      @service_name = options[:service_name]
      @container    = options[:container]
    end

    # Provided for Enumerable functionality
    #
    # @param block [block] a block to evaluate
    # @return [Frodo::Entity] each entity in turn from this set
    # def each(&block)
    #   query.execute.each(&block)
    # end

    # # Return the first `n` Entities for the set.
    # # If count is 1 it returns the single entity, otherwise its an array of entities
    # # @return [Frodo::EntitySet]
    # def first(count = 1)
    #   result = query.limit(count).execute
    #   count == 1 ? result.first : result.to_a
    # end

    # # Returns the number of entities within the set.
    # # Not supported in Microsoft CRM2011
    # # @return [Integer]
    # def count
    #   query.count
    # end

    # Create a new Entity for this set with the given properties.
    # @param properties [Hash] property name as key and it's initial value
    # @return [Frodo::Entity]
    def new_entity(properties = {})
      Frodo::Entity.with_properties(properties, entity_options)
    end

    # Returns a query targetted at the current EntitySet.
    # @param options [Hash] query options
    # @return [Frodo::Query]
    def query(options = {})
      Frodo::Query.new(self, options)
    end


    def entity_primary_key()
      new_entity.primary_key
    end

    # Find the Entity with the supplied key value.
    # @param key [to_s] primary key to lookup
    # @return [Frodo::Entity,nil]
    # def [](key, options={})
    #   properties_to_expand = if options[:expand] == :all
    #     new_entity.navigation_property_names
    #   else
    #     [ options[:expand] ].compact.flatten
    #   end

    #   query.expand(*properties_to_expand).find(key)
    # end

    # Write supplied entity back to the service.
    # TODO Test this more with CRM2011
    # @param entity [Frodo::Entity] entity to save or update in the service
    # @return [Frodo::Entity]
    # def <<(entity)
    #   url_chunk, options = setup_entity_post_request(entity)

    #   result = execute_entity_post_request(options, url_chunk)
    #   if entity.is_new?
    #     doc = ::Nokogiri::XML(result.body).remove_namespaces!
    #     primary_key_node = doc.xpath("//content/properties/#{entity.primary_key}").first
    #     entity[entity.primary_key] = primary_key_node.content unless primary_key_node.nil?
    #   end

    #   unless result.status.to_s =~ /^2[0-9][0-9]$/
    #     entity.errors << ['could not commit entity']
    #   end

    #   entity
    # end

    # The Frodo::Service this EntitySet is associated with.
    # @return [Frodo::Service]
    # @api private
    def service
      @service ||= Frodo::ServiceRegistry[service_name]
    end

    # Options used for instantiating a new Frodo::Entity for this set.
    # @return [Hash]
    # @api private
    def entity_options
      {
        service_name: service_name,
        type:         type,
        entity_set:   self
      }
    end

  end
end
