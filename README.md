# Boiled_Cucumber_In_Watir

## Description
A simple ruby script to help parse our the unique gherkin scripts in a directory

## Setup

* 1) Place the gherkin_dict.rb file in the same directory which contains your features folder.  They should be side by side.
* 2) execute ``ruby gherkin_dict.rb``
* 3) A gherkin_dictionary.html should be generated with all of your unique steps sorted
* Note : Anything in double quotes or in <> are ignored when evaluating for uniqueness
