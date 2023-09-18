ProjectQuery.class_eval do
  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= {} # { 'status' => { operator: "=", values: ['1'] } }
  end

  def initialize_available_filters
    add_available_filter("labs",         type: :string)# ,     values: lambda {lab_values},                               label: :field_lab_partner)
    
    add_available_filter("support_id",   type: :list,    values: Support.all.collect { |s| [ s.name, s.id.to_s ] }, label: :field_support)
    add_available_filter("year",         type: :list,    values: year_values,                                       label: :field_year)
    add_available_filter("status",       type: :list,    values: lambda {project_statuses_values} )
    add_available_filter("coordinators", type: :list,    values: lambda {member_values('Coordinateur')},            label: :field_coordinators)
    add_available_filter("participants", type: :list,    values: lambda {member_values},                            label: :field_participants)
  end

  def project_statuses_values
    [
      [l(:project_status_active), "#{Project::STATUS_ACTIVE}"],
      [l(:project_status_closed), "#{Project::STATUS_CLOSED}"],
      [l(:project_status_archived), "#{Project::STATUS_ARCHIVED}"]
    ]
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
    end.sort_by { |_key, value| value[:name] }.to_h
    
    results = users.collect { |k,v| [ v[:name], v[:ids].join('|') ] }
    results.prepend(['', ''])
    results
  end

  def year_values
    available_years = Project.all.inject([]) do |arr, p|
      arr << p.starts_date.year if p.starts_date && !arr.include?(p.starts_date.year) && p.starts_date.year > 2000 && p.starts_date.year < 3000
      arr << p.ends_date.year   if p.ends_date && !arr.include?(p.ends_date.year) && p.ends_date.year > 2000 && p.ends_date.year < 3000
      arr
    end.sort

    results = (available_years.min..available_years.max).map { |i| [ i.to_s, i.to_s ] }
    results.prepend(['', ''])
    results
  end

  def sql_for_labs_field(field, operator, value)
    value = value.map { |v| v.split('|') }.flatten
    sql_for_field(field, operator, value, Lab.table_name, "name")
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

  def sql_for_year_field(field, operator, value)
    neg   = (operator == '!' ? 'NOT' : '')

    query = value.inject([]) do |arr, val|
      arr << "(#{Project.table_name}.starts_date < '#{Date.new((val.to_i + 1), 1, 1)}' AND #{Project.table_name}.ends_date >= '#{Date.new(val.to_i, 1, 1)}')"
      arr << "(#{Project.table_name}.starts_date >= '#{Date.new(val.to_i, 1, 1)}' AND #{Project.table_name}.starts_date < '#{Date.new((val.to_i + 1), 1, 1)}' AND #{Project.table_name}.ends_date IS NULL)"
      arr
    end

    subquery = "SELECT id FROM #{Project.table_name} WHERE #{query.join(' OR ')}"
    "#{neg} #{Project.table_name}.id IN (#{subquery})"
  end

  def results_scope(options = {})
    order_option  = [ group_by_sort_order, (options[:order] || sort_clause) ].flatten.reject(&:blank?)
    order_option << "#{Project.table_name}.lft ASC"

    scope = base_scope.
      order(order_option).
      joins(joins_for_order_statement(order_option.join(','))).
      left_joins(:labs, :members)

    if has_custom_field_column?
      scope = scope.preload(:custom_values)
    end

    if has_column?(:parent_id)
      scope = scope.preload(:parent)
    end

    scope.distinct
  end
end