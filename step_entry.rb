class StepEntry
  def initialize(original_step, cleaned_step, uses)
    @original_step=original_step
    @cleaned_step=cleaned_step
    @uses=uses
  end

  def cleaned_step()
    @cleaned_step
  end
  def original_step()
    @original_step
  end
  def uses()
    @uses
  end
  def set_uses(uses)
    @uses = uses
  end

end
