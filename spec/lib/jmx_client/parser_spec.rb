base_dir = File.expand_path('../../../../', __FILE__)
require "#{base_dir}/spec/spec_helper"

describe JmxClient::Parser do

  JMXCLIENT = "#{base_dir}/bin/cmdline-jmxclient.jar"

  let(:default_command) { "java -jar #{JMXCLIENT} - 127.0.0.1:18080" }
  let(:output) { `#{command} 2>&1` }
  let(:parsed_output) { JmxClient::Parser.parse(output) }
  subject { parsed_output }

  context 'compound outputs' do
    let(:command) { "#{default_command} java.lang:type=Memory HeapMemoryUsage NonHeapMemoryUsage" }

    specify { subject.keys.count.should == 2 }

    it 'has both attributes' do
      attributes = %w(HeapMemoryUsage NonHeapMemoryUsage)
      attributes.each { |attribute| subject.keys.should include(attribute) }
    end

    describe 'sub attributes' do
      subject { parsed_output }

      it 'has all sub attributes' do
        debugger
        expected = %w(committed init max used)
        subject.each do |_, actual|
          expected.each { |sub_attribute| actual.keys.should include(sub_attribute) }
          actual.keys.size.should == expected.size
        end
      end
    end

  end

  context 'multiple single line outputs' do
    let(:command) {}
  end

  context 'compound outputs and single line outputs' do
    let(:command) {}
  end

end
