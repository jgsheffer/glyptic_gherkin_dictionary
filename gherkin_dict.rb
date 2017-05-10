require 'fuzzystringmatch'

def create_dictionary(features_location="**/features/*", output="gherkin_dictionary.html")
  $number_of_features = 0
  $feature_collection_string=""
  out_file = File.new(output, "w")
  features = []
  contents = ''
  files = Dir.glob(features_location).select{ |e| File.file? e}
  files.each do |file|
    features << file if file.to_s.include?('.feature')
  end
  if (features == nil || features.empty?)
      raise "Your file location #{features_location} does not contain any features"
  else
    features.each do |feature_file|
      $number_of_features = $number_of_features+1
      $feature_collection_string = "#{$feature_collection_string} #{feature_file} <br/>"
      current_file = File.open(feature_file.to_s, "rb").read
      contents = contents + current_file
    end
  end
  contents_cleaned = contents.gsub(/|.*|/, " ").gsub("Examples:", "")
  gherkin_dict = find_possible_duplicates(get_gherkin_dictionary(contents))

  out_file.puts(generate_html_string(gherkin_dict))
  out_file.close
  puts "All done"
end


def get_gherkin_dictionary(contents)
  gherkin_dictionary = []
  contents.each_line do |line|
    if(line != nil && line != "" && is_gherkin_step(line))
      line = add_place_holders(line)
      exists_in_dictonary = false
      gherkin_dictionary.each do |dictonary_element|
        cleaned_line = clean_gherkin_string(line)
        if(cleaned_line == dictonary_element.cleaned_step)
          exists_in_dictonary = true
          dictonary_element.set_uses(dictonary_element.uses+1)
          break
        end
      end
        gherkin_dictionary << StepEntry.new(correct_spacing(line.strip), clean_gherkin_string(line), 1) if !exists_in_dictonary
    end
  end
  gherkin_dictionary
end

def find_possible_duplicates(dictionary)
  string_compare = FuzzyStringMatch::JaroWinkler.create( :pure )
  updated_dictionary = []
  total_number_of_steps_parsed = dictionary.size
  current_number_of_steps_parsed = 0
  dictionary.each do |step_entry|
    puts "Steps parsed #{current_number_of_steps_parsed}/#{total_number_of_steps_parsed}"
    current_number_of_steps_parsed = current_number_of_steps_parsed + 1
    dictionary.each do |step_entry_to_compare|
      similarity = string_compare.getDistance(step_entry.cleaned_step, step_entry_to_compare.cleaned_step )*100
      if (88 < similarity && similarity < 100)
        step_entry.add_possible_duplicate(step_entry_to_compare.original_step, similarity)
      end
    end
    updated_dictionary << step_entry
  end
  updated_dictionary
end

def generate_duplicate_blob(duplicate_array)
  duplicate_found = false
  beginning_string = "<details><summary>Possible Duplicate Steps</summary><pre class=\"prettyprint\"><ul>"
  end_string="</ul></pre></details>"
  list_string=""
  if(duplicate_array != nil)
    duplicate_array.each do |duplicate_step|
      duplicate_found = true
      list_string="#{list_string}<li>Similarity: #{duplicate_step.percentage_of_similarity} Step: #{duplicate_step.step}</li>"
    end
    if(duplicate_found)
      beginning_string+list_string+end_string
    end
  end
end




def clean_gherkin_string(string)
 string.downcase.strip.gsub(/^given /, "").gsub(/^when /, "").gsub(/^then /, "").gsub(/^but /, "").gsub(/^and /, "").gsub(/".*"/, "").gsub(/<.*>/, "").gsub(/\s\s/, " ").gsub(/|.*|/, " ").gsub(/\n/, " ").gsub(/#.*/, "").strip
end

def correct_spacing(string)
 string.strip.gsub(/^When /, "&nbsp;When ").gsub(/^Then /, "&nbsp;Then ").gsub(/^But /, "&nbsp;&nbsp;But ").gsub(/^And /, "&nbsp;&nbsp;And ").gsub(/#.*/, "")
end

def is_gherkin_step(string)
  normalized_string = string.downcase.strip
  normalized_string.start_with?("given") || normalized_string.start_with?("when") || normalized_string.start_with?("then") || normalized_string.start_with?("and") || normalized_string.start_with?("but")
end

def format_gherkin_step(string)
  string.gsub("Given", '<b>Given</b>').gsub("When", '<b>When</b>').gsub("Then", '<b>Then</b>').gsub("And", '<b>And</b>').gsub("But", '<b>But</b>').gsub(/"parameter"/,  '<span style="color: #0000ff">"parameter"</span>')
end

def add_place_holders(string)
  string.gsub(/"</, '"').gsub(/>"/, '"').gsub(/<.*>/, '"parameter"').gsub(/"[^"]*"/, '"parameter"')
end

def generate_html_string(gherkin_dictionary)
  gherkin_dictionary.sort_by!{ |step_entry| step_entry.cleaned_step.downcase }
  features_parsed="<details><summary>#{$number_of_features} features parsed</summary><pre class=\"prettyprint\">#{$feature_collection_string}</pre></details>"
  beginning_html = '<!DOCTYPE html><html><head><style>table {font-family:monospace, arial, sans-serif;border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd;text-align: left;padding: 8px;}tr:nth-child(even) {background-color: #dddddd;}</style></head><body><table><tr><th>#</th><th>Step</th><th>Uses</th></tr><tr>'
  ending_html = '</table>'+features_parsed+'</body></html>'
  final_html = beginning_html
  step_number = 1
  gherkin_dictionary.each do |step_entry|
    final_html = final_html + "<tr><td>#{step_number}</td><td>#{format_gherkin_step(step_entry.original_step)}#{generate_duplicate_blob(step_entry.possible_duplicates)}</td><td>#{step_entry.uses}</td></tr>"
    step_number = step_number + 1
  end
  final_html+ending_html
end

class DuplicateEntry
  def initialize(step, percentage_of_similarity)
    @step=step
    @percentage_of_similarity=percentage_of_similarity
  end

  def step()
    @step
  end
  def percentage_of_similarity()
    @percentage_of_similarity
  end
end

class StepEntry
  @possible_duplicates=[]
  def initialize(original_step, cleaned_step, uses, possible_duplicates=[])
    @original_step=original_step
    @cleaned_step=cleaned_step
    @uses=uses
    @possible_duplicates=possible_duplicates
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
    def possible_duplicates()
      @possible_duplicates
    end
    def add_possible_duplicate(step, percentage_of_similarity)
      @possible_duplicates << DuplicateEntry.new(step, percentage_of_similarity)
    end
end



create_dictionary()
