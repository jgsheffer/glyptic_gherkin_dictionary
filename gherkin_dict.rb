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
      $feature_collection_string = "#{$feature_collection_string} #{feature_file} :::"
      contents = File.open(feature_file.to_s, "rb").read
    end
  end
  contents_cleaned = contents.gsub(/|.*|/, " ").gsub("Examples:", "")
  out_file.puts(generate_html_string(get_gherkin_dictionary(contents)))
  out_file.close
end


def get_gherkin_dictionary(contents)
  gherkin_dictionary = []
  contents.each_line do |line|
    if(line != nil && line != "" && is_gherkin_step(line))
      line = add_place_holders(line)
      exists_in_dictonary = false
      gherkin_dictionary.each do |dictonary_element|
        cleaned_line = clean_gherkin_string(line)
        cleaned_dictonary_element = clean_gherkin_string(dictonary_element)
        if(cleaned_line == cleaned_dictonary_element)
          exists_in_dictonary = true
          break
        end
      end
        gherkin_dictionary << line.strip if !exists_in_dictonary
    end
  end
  gherkin_dictionary.sort
end





def clean_gherkin_string(string)
 string.downcase.strip.gsub(/^given /, "").gsub(/^when /, "").gsub(/^then /, "").gsub(/^but /, "").gsub(/^and /, "").gsub(/".*"/, "").gsub(/<.*>/, "").gsub(/\s\s/, " ").gsub(/|.*|/, " ").gsub(/\n/, " ").strip
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
  features_parsed="<details><summary>#{$number_of_features} features parsed</summary><pre class=\"prettyprint\">#{$feature_collection_string}</pre></details>"
  beginning_html = '<!DOCTYPE html><html><head><style>table {font-family: arial, sans-serif;border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd;text-align: left;padding: 8px;}tr:nth-child(even) {background-color: #dddddd;}</style></head><body><table><tr><th>Step</th><th>Uses</th></tr><tr>'
  ending_html = '</table>'+features_parsed+'</body></html>'
  final_html = beginning_html
  gherkin_dictionary.each do |step|
    final_html = final_html + '<tr><td>'+ format_gherkin_step(step) +'</td><td></td></tr>'
  end
  final_html+ending_html
end

create_dictionary()
