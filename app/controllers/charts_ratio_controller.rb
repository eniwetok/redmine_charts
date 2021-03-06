class ChartsRatioController < ChartsController

  unloadable
  
  protected

  def get_data
    rows = ChartTimeEntry.get_aggregation(@grouping, @conditions)

    bigger_rows = []
    total_hours = 0
    other_value = 0
    other_no = 0

    rows.each do |row|
      total_hours += row.logged_hours.to_f
    end

    rows.each do |row|
      if row.group_id.to_i == 0 or ((other_value + row.logged_hours.to_f)/total_hours) < 0.05
        other_value += row.logged_hours.to_f
        other_no += 1
      else
        bigger_rows << row
      end
    end

    if other_no > 1
      rows = bigger_rows
      other_row = Struct.new(:value_x, :value_y, :group_id).new
      other_row.value_y = other_value
      other_row.group_id = 0
      other_row.grouping = :others
      rows << other_row
    end

    labels = []
    set = []

    if rows.empty?
      labels << l(:charts_ratio_label, { :label => l(:charts_ratio_none) })
      set << [1, l(:charts_ratio_hint, { :label => l(:charts_ratio_none), :hours => 0, :percent => 0, :total_hours => 0 })]
    else
      rows.each do |row|
        labels << l(:charts_ratio_label, { :label => RedmineCharts::GroupingUtils.to_string(row.group_id, row.grouping.to_sym, l(:charts_ratio_others)) })
        hint = l(:charts_ratio_hint, { :label => RedmineCharts::GroupingUtils.to_string(row.group_id, row.grouping.to_sym, l(:charts_ratio_others)), :hours => RedmineCharts::Utils.round(row.logged_hours), :percent => get_percent(row.logged_hours, total_hours), :total_hours => RedmineCharts::Utils.round(total_hours) })
        set << [RedmineCharts::Utils.round(row.logged_hours), hint]
      end
    end

    {
      :labels => labels,
      :count => rows.size,
      :max => 0,
      :sets => {"" => set}
    }
  end

  def get_title
    l(:charts_link_ratio)
  end
  
  def get_help
    l(:charts_ratio_help)
  end
  
  def get_type
    :pie
  end

  private

  def get_percent(value, total)
    if total > 0      
      (value.to_f/total*100).round
    else
      0
    end
  end
  
end
