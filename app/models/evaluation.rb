class Evaluation < ActiveRecord::Base
  attr_accessible :user_id, :assignment_id, :lo_id, :evmethod_id, :completed_at, 
  :item1, :item2, :item3, :item4, :item5, :item6, :item7, :item8, :item9, :item10, :item11, :item12, :item13, :item14, :item15, :item16, :item17, :item18, :item19, :item20, :item21, :item22, :item23, :item24, :item25,
  :titem1, :titem2, :titem3, :titem4, :titem5, :titem6, :titem7, :titem8, :titem9, :titem10,
  :sitem1, :sitem2, :sitem3, :sitem4, :sitem5

  belongs_to :user
  belongs_to :lo
  belongs_to :evmethod
  belongs_to :assignment #optional

  validates :user_id,
  :presence => true

  validates :lo_id,
  :presence => true

  validates :evmethod_id,
  :presence => true


  def readable_completed_at
    readable_date(self.completed_at)
  end


  private

  def readable_date(date)
    unless date.nil?
      date.strftime("%d/%m/%Y %H:%M %P")
      #For Ruby < 1.9
      # date.strftime("%d/%m/%Y %H:%M %p").sub(' AM', ' am').sub(' PM', ' pm')
    else
      ""
    end
  end
  
end
