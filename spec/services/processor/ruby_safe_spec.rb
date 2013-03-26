require "bootstrap"
require "services/processor/ruby_safe"

describe Services::Processor::RubySafe do
  let( :service ) { described_class.new }

  describe "processing a document" do
    let( :input ) do
      [ { "server" => "alienhost", "level" => "error", "type" => "Ruby Object",
          "message" => "REQUESTING PAGE: POST /themes with {\"theme\"=>{\"link2_text\"=>\"\", \"name\"=>\"Valentine Gifts\", \"link2\"=>\"\", \"slug\"=>\"valentine_gifts\", \"pinterest_link\"=>\"\", \"introduction\"=>\"\", \"theme_image\"=>{\"uploaded_data\"=>#<ActionController::TestUploadedFile:0x10a268be8 @original_filename=\"square4.png\", @tempfile=#<File:/var/folders/__/b7bshk5x21x79gg7rwr7dxdh0000gn/T/square49087-0.png>, @content_type=\"image/png\">}, \"curator_username\"=>\"\", \"link\"=>\"\", \"curated_by\"=>\"\", \"link_text\"=>\"\"}, \"commit\"=>\"Create theme\"} and HTTP headers {\"HTTP_REFERER\"=>\"/themes/new\"}" }
      ]
    end
    let( :output ) do
      [ { "server" => "alienhost", "level" => "error", "type" => "Ruby Object",
          "message" => "REQUESTING PAGE: POST /themes with {\"theme\"=>{\"link2_text\"=>\"\", \"name\"=>\"Valentine Gifts\", \"link2\"=>\"\", \"slug\"=>\"valentine_gifts\", \"pinterest_link\"=>\"\", \"introduction\"=>\"\", \"theme_image\"=>{\"uploaded_data\"=>\"#<ActionController::TestUploadedFile:0x10a268be8 @original_filename=\\\"square4.png\\\", @tempfile=#<File:/var/folders/__/b7bshk5x21x79gg7rwr7dxdh0000gn/T/square49087-0.png>, @content_type=\\\"image/png\\\">\"}, \"curator_username\"=>\"\", \"link\"=>\"\", \"curated_by\"=>\"\", \"link_text\"=>\"\"}, \"commit\"=>\"Create theme\"} and HTTP headers {\"HTTP_REFERER\"=>\"/themes/new\"}" }
      ]
    end

    it "should safely quote any ruby objects in the message" do
      [ input, output ].transpose.each do |(idoc, odoc)|
        service.process( idoc ).should == odoc
      end
    end
  end
  
end
