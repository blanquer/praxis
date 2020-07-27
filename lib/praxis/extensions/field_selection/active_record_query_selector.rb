# frozen_string_literal: true
module Praxis
  module Extensions
    module FieldSelection
      class ActiveRecordQuerySelector
        attr_reader :selector, :query
        # Gets a dataset, a selector...and should return a dataset with the selector definition applied.
        def initialize(query:, selectors:)
          @selector = selectors
          @query = query
        end

        # def generate(debug: false)
        #   # TODO: unfortunately, I think we can only control the select clauses for the top model 
        #   # (as I'm not sure ActiveRecord supports expressing it in the join...)
        #   @query = add_select(query: query, selector_node: selector)
        #   eager_hash = _eager(selector)

        #   @query = @query.includes(eager_hash)          
        #   explain_query(query, eager_hash) if debug

        #   @query
        # end

        def select_fields(selector_node:)
          #annotation = "'#{selector_node.resource.name}' as _resource"
          annotation = :updated_at
          (selector_node.select + [selector_node.resource.model.primary_key.to_sym] + [annotation]).to_a
        end

        def generate(debug: false)
          require 'deep_pluck'
          pluck_array = _eager(selector)

          # EXPLORING TOJSON
#           thething = query.includes(:current_funds)
# #          binding.pry
#           #rr = thething.load

# #           thething.records => thething.load => thething.exec_queries
# #           From: /Users/blanquer/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/activerecord-5.2.4.3/lib/active_record/relation.rb:547 ActiveRecord::Relation#exec_queries:
# #           From: /Users/blanquer/.rbenv/versions/2.7.1/lib/ruby/gems/2.7.0/gems/activerecord-5.2.4.3/lib/active_record/relation.rb:560 ActiveRecord::Relation#exec_queries:

# #     555:                   rows = connection.select_all(relation.arel, "SQL")
# #     556:                   join_dependency.instantiate(rows, &block)
# #     557:                 end.freeze
# #     558:               end
# #     559:             else
# #  => 560:               klass.find_by_sql(arel, &block).freeze
# # .....
# # 563:           preload = preload_values
# # 564:           preload += includes_values unless eager_loading?
# # => 565:           preloader = nil
# # 566:           preload.each do |associations|
# # 567:             preloader ||= build_preloader
# # 568:             preloader.preload @records, associations
# # 569:           end
# # 570:
# binding.pry
# preloader = ActiveRecord::Associations::Preloader.new
# preloader.preloaders_for_one(:current_funds, [], nil)

# rhs_klass = Im::Fund
# rs = []
# reflection = rhs_klass.reflection_for(:current_funds)
# scope = nil
# preloader.preloader_for(query, rs) => Th
# preloader_for = ThroughAssociation.new(rhs_klass, rs, reflection, scope)
# preloader_for.run self
# preloader_for

#           thething.as_json

          #@query = @query.includes(eager_hash)
          #ActiveRecord::Base.logger = Logger.new(STDOUT)
          results = query.deep_pluck(*pluck_array)

          explain_query(results, eager_hash) if debug

          top_model = selector.resource.model
          top_model_class = Praxis::Mapper::ReadOnlyModel.for(top_model)
          results.map do |result|
            top_model_class.new(result, selector)
          end
        end

        # def add_select(query:, selector_node:)
        #   # We're gonna always require the PK of the model, as it is a special case for AR, and the app itself 
        #   # might assume it is always there and not be surprised by the fact that if it isn't, it won't blow up
        #   # in the same way as any other attribute not being loaded...i.e., ActiveModel::MissingAttributeError: missing attribute: xyz
        #   select_fields = selector_node.select + [selector_node.resource.model.primary_key.to_sym]
        #   select_fields.empty? ? query : query.select(*select_fields)
        # end



        def _eager(selector_node)
          the_fields = select_fields(selector_node: selector_node)
          selector_node.tracks.each_with_object(the_fields) do |(track_name, track_node), h|
            h.push({ "#{track_name}" => _eager(track_node) })
          end
        end

        def explain_query(query, eager_hash)
          prev = ActiveRecord::Base.logger
          ActiveRecord::Base.logger = Logger.new(STDOUT)
          ActiveRecord::Base.logger.debug("Query plan for ...#{selector.resource.model} with selectors: #{JSON.generate(selector.dump)}")
          ActiveRecord::Base.logger.debug(" ActiveRecord query: #{selector.resource.model}.includes(#{eager_hash})")
          query.explain
          ActiveRecord::Base.logger.debug("Query plan end")
          ActiveRecord::Base.logger = prev
        end
      end
    end
  end
end