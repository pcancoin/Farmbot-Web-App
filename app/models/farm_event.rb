# Not the same thing as a Regimen. A farm_event is a "dumb" list of sequecnes that
# are executed at fixed intervals. FarmEvents are less flexible than Regimens
# because they can only perform one sequence. Also unlike Regimens, they can run
# forever.
class FarmEvent < ActiveRecord::Base
  NEVER              = :never
  UNITS_OF_TIME      = %w(never minutely hourly daily
                          weekly monthly yearly) << NEVER
  EXECUTABLE_CLASSES = [Sequence, Regimen]
  belongs_to :executable, polymorphic: true
  validates :executable, presence: true
  belongs_to :device
  validates :device_id, presence: true

  class NullEventRules

    def initialize(obj)
      @obj = obj
    end

    def next_occurrence(*)
      @obj.start_time
    end

    def occurrences_between(*)
      []
    end
  end

  def farm_event_rules
    return NullEventRules.new(self) if time_unit.to_sym == NEVER
    @farm_event_rules ||= IceCube::Schedule.new(start_time, end_time: end_time) do |sch|
      sch.add_recurrence_rule IceCube::Rule.send(time_unit.to_sym, repeat)
    end
  end

  def calculate_next_occurence
    farm_event_rules.next_occurrence
  end

  def between(start, finish)
    # Just for reference for later. Probably should just delegate.
    farm_event_rules.occurrences_between(start, finish)
  end
end