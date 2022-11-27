require 'gerty/models/card'

RSpec.describe Gerty::Common do
  it "has a version number" do
    expect(Gerty::Common::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(Gerty::Aws::DynamoDb::Cards).to be_a(Gerty::Aws::DynamoDb::Cards)
  end
end
