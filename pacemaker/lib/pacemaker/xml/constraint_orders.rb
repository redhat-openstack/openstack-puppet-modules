module Pacemaker
  # functions related to constraint_orders constraints
  # main structure "constraint_orders"
  module ConstraintOrders
    # get order constraints and use memoization on the list
    # @return [Hash<String => Hash>]
    def constraint_orders
      return @orders_structure if @orders_structure
      @orders_structure = constraints 'rsc_order'
    end

    # check if order constraint exists
    # @param id [String] the constraint id
    # @return [TrueClass,FalseClass]
    def constraint_order_exists?(id)
      constraint_orders.key? id
    end

    # add a order constraint
    # @param order_structure [Hash<String => String>] the location data structure
    def constraint_order_add(order_structure)
      order_patch = xml_document
      order_element = xml_rsc_order order_structure
      raise "Could not create XML patch from colocation '#{order_structure.inspect}'!" unless order_element
      order_patch.add_element order_element
      wait_for_constraint_create xml_pretty_format(order_patch.root), order_structure['id']
    end

    # remove an order constraint
    # @param id [String] the constraint id
    def constraint_order_remove(id)
      wait_for_constraint_remove "<rsc_order id='#{id}'/>\n", id
    end

    # generate rsc_order elements from data structure
    # @param data [Hash]
    # @return [REXML::Element]
    def xml_rsc_order(data)
      return unless data && data.is_a?(Hash)
      xml_element 'rsc_order', data, 'type'
    end
  end
end
