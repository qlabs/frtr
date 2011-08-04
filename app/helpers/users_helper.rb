module UsersHelper
  def formatted_record_date(the_date)
    if the_date > 60.minutes.ago
      "#{((Time.now.utc - the_date) / 60).to_i.to_s} minutes ago"
    elsif the_date > 24.hours.ago
      "#{((Time.now.utc - the_date) / 60 / 60).to_i.to_s} hours ago"
    else
      "#{((Time.now.utc - the_date) / 60 / 60 / 24).to_i.to_s} days ago"  
    end
  end
end
