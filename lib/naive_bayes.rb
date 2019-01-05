# Bayes Theorem
# P(A|B) = P(B|A) * P(A) / P(B)

# Terminology
# An ITEM is made up of FEATURES
# An ITEM belongs to a CLASS

# Bayes With Our Terminology
# P(Class | Item) = P(Item | Class) * P(Class) / P(Item)

# However, when classifying, P(Item) is the same across all calcualtions
# So we don't bother to calculate it
class NaiveBayes
  
  class << self
    def load(db_path)
      data = ""
      File.open(db_path) do |f|
        while line = f.gets
          data << line
        end
      end
      Marshal.load(data)
    end
  end
    
  attr_accessor :db_filepath  
  
  def initialize(*klasses)
    @features_count = {}
    @klass_count = {}
    @klasses = klasses
    
    klasses.each do |klass|
      @features_count[klass] = Hash.new(0.0)
      @klass_count[klass] = 0.0
    end
  end
  
  def train(klass, *features)
    features.uniq.each do |feature|
      @features_count[klass][feature] += 1
    end
    @klass_count[klass] += 1
  end
  
  def untrain(klass, *features)
    features.uniq.each do |feature|
      @features_count[klass][feature] -= 1
    end
    @klass_count[klass] -= 1
  end
  
  #P(Class | Item) = P(Item | Class) * P(Class)
  def classify(*features)
    scores = {}
    @klasses.each do |klass|
      scores[klass] = (prob_of_item_given_a_class(features, klass) * prob_of_class(klass))
    end
    return [] if scores.values.reduce(:+) == 0.0
    scores.sort {|a,b| b[1] <=> a[1]}[0]
  end
  
  def save
    raise "You haven't set a db_filpath, I dont know where to save" if @db_filepath.nil?
    File.open(@db_filepath, "w+") do |f|
      f.write(Marshal.dump(self))
    end
  end
  
  private
    
  # P(Item | Class)
  def prob_of_item_given_a_class(features, klass)
    a = features.inject(1.0) do |sum, feature|
      prob = prob_of_feature_given_a_class(feature, klass)
    end
  end
  
  # P(Feature | Class)
  def prob_of_feature_given_a_class(feature, klass)
    # If there is not any sentence in our trained models we return nil value
    @feature = @features_count[klass][feature.to_sym]
    feature.nil? ? feature : @features_count[klass][feature.to_sym] / @klass_count[klass]
  end
  
  # P(Class)
  def prob_of_class(klass)
    @klass_count[klass] / total_items
  end
  
  def total_items
    @klass_count.inject(0) do |sum, klass|
      sum += klass[1]
    end
  end
  
end
