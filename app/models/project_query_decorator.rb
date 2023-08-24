ProjectQuery.class_eval do
  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= {}
  end

  def initialize_available_filters
    add_available_filter("labs",         type: :list, values: lambda {lab_values},                               label: :field_lab_partner)
    add_available_filter("coordinators", type: :list, values: lambda {member_values('Coordinateur')},            label: :field_coordinators)
    add_available_filter("participants", type: :list, values: lambda {member_values},                            label: :field_participants)
    add_available_filter("support_id",   type: :list, values: Support.all.collect { |s| [ s.name, s.id.to_s ] }, label: :field_support)
  end

  def lab_values
    labs = Lab.all.inject({}) do |h, lab|
      h[lab.name.parameterize]       ||= { name: lab.name, ids: [] }
      h[lab.name.parameterize][:ids]  << lab.id
      h
    end.sort.to_h

    labs.collect { |k,v| [ v[:name], v[:ids].join('|') ] }
  end

  def member_values(role = nil)
    members = Member.includes(:user)
    members = members.includes(:roles).where(roles: { name: 'Coordinateur' }) if role.present?

    users = members.inject({}) do |h, m|
      if m.user
        h[m.user_id]       ||= { name: "#{m.user.firstname} #{m.user.lastname}", ids: [] }
        h[m.user_id][:ids]  << m.id
      end

      h
    end.sort.to_h

    users.collect { |k,v| [ v[:name], v[:ids].join('|') ] }
  end

  def sql_for_labs_field(field, operator, value)
    value = value.map { |v| v.split('|') }.flatten
    sql_for_field(field, operator, value, Lab.table_name, "id")
  end

  def sql_for_coordinators_field(field, operator, value)
    sql_for_members_field(field, operator, value)
  end

  def sql_for_participants_field(field, operator, value)
    sql_for_members_field(field, operator, value)
  end

  def sql_for_members_field(field, operator, value)
    value = value.map { |v| v.split('|') }.flatten
    sql_for_field(field, operator, value, Member.table_name, "id")
  end

  def results_scope(options = {})
    order_option  = [ group_by_sort_order, (options[:order] || sort_clause) ].flatten.reject(&:blank?)
    order_option << "#{Project.table_name}.lft ASC"

    scope = base_scope.
      order(order_option).
      joins(joins_for_order_statement(order_option.join(','))).
      joins(:labs, :members)

    if has_custom_field_column?
      scope = scope.preload(:custom_values)
    end

    if has_column?(:parent_id)
      scope = scope.preload(:parent)
    end

    scope.distinct
  end
end