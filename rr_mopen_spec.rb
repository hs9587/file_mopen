# coding: utf-8
RSpec.configure{|config| config.mock_with :rr }
#require './mopen'
class File
  def self.mopen_with(fnames, hundlers, block)
    "fnames:#{fnames.inspect}, hundlers:#{hundlers.inspect}.\n".display if $VERBOSE
    if fnames.size > 0 then
      self.open(*(fnames.shift)) do |f|
        mopen_with fnames, hundlers << f, block
      end # self.open(*(fnames.shift)) do |f|
    else# if fnames.size > 0
      block.call *hundlers
    end # if fnames.size > 0
  end # def self.mopen_with(fnames, hundlers, block)
  private_class_method :mopen_with

  def self.mopen(*fnames, &block)
    mopen_with fnames, [], block
  end # def self.mopen(*fnames)
end # class File

require 'tempfile'
describe File do
  subject{ File }

  describe '#mopen' do
    context 'a file' do
      around(:each) do |example|
        temp = Tempfile.new 'mopen_spec'
        @fname = temp.path
        temp.close false
        example.run
        temp.close true
      end # around(:each) do |example|

      it 'should open a file' do
        mock.proxy(subject).open(@fname)
        subject.mopen(@fname){}
      end # it 'should open a file' do

      it 'should open with a block' do
        mock(block_ = Object.new).called
        subject.mopen(@fname){ block_.called }
      end # it 'should open with a block' do
    end # context 'a file' do

class File
  def closed?
    inspect.end_with? ' (closed)>'
  end # def closed?
end # class File

    10.times do |i|
      context "#{i} files" do
        around(:each) do |example|
          temps = (1..i).map{ Tempfile.new 'mopen_spec' }
          @fnames = temps.map{ |t| t.path }
          temps.each{ |t| t.close false }
          example.run
          temps.each{ |t| t.close true}
        end # around(:each) do |example|

        it "should open #{i} files" do
          @fnames.each{ |f| mock.proxy(subject).open f }
          subject.mopen(*@fnames){}
        end # it "should open #{i} files" do

        it 'should open with a block' do
          mock(block_ = Object.new).called
          subject.mopen(*@fnames){ block_.called }
        end # it 'should open with a block' do

        it "should have #{i} file hundlers" do
          subject.mopen(*@fnames){ |*fs| fs.size.should == i }
        end # it "should have #{i} file hundlers" do

        it "should have #{i} files" do
          subject.mopen(*@fnames){ |*fs| fs.map{|f|f.path}.should == @fnames }
        end # it "should have #{i} files" do

        it "should have #{i} instances of File" do
          subject.mopen(*@fnames) do |*fs|
            fs.each{ |f| f.should be_an_instance_of(File) }
          end # subject.mopen(*@fnames) do |*fs|
        end # it "should have #{i} instances of File" do

        it "should have #{i} open files" do
          subject.mopen(*@fnames) do |*fs|
            fs.each{ |f| lambda{ f.stat }.should_not raise_error(IOError) }
          end # subject.mopen(*@fnames) do |*fs|
        end # it "should have #{i} open files" do

        it "should have #{i} files, and should be closed streams" do
          fs = []
          subject.mopen(*@fnames){ |*fs_| fs = fs_}
          "fs: #{fs.inspect}.\n".display if $VERBOSE
          fs.each do |f|
            lambda{ f.stat }.should raise_error(IOError,'closed stream')
          end # fs.each do |f|
        end # it "should have #{i} files, and should be closed streams" do

        it "should have #{i} files, and close these" do
          fs = []
          subject.mopen(*@fnames){ |*fs_| fs = fs_}
          fs.each{ |f| f.inspect.should be_end_with(' (closed)>') }
        end # it "should have #{i} files, and close these" do

        it "should have #{i} files, and closed" do
          fs = []
          subject.mopen(*@fnames){ |*fs_| fs = fs_}
          fs.each{ |f| f.should be_closed }
        end # it "should have #{i} files, and closed" do

        it "should have #{i} non-closed files" do
          subject.mopen(*@fnames) do |*fs|
            fs.each{ |f| f.should_not be_closed }
          end # subject.mopen(*@fnames) do |*fs|
        end # it "should have #{i} non-closed files" do

        it "should be closed if anything raised" do
          fs = []
          lambda do
            subject.mopen(*@fnames){ |*fs_| fs = fs_; raise 'anything' }
          end.should raise_error RuntimeError, 'anything'
          "fs: #{fs.inspect}.\n".display if $VERBOSE
          fs.each{ |f| f.should be_closed }
        end # it "should be closed if anything raised" do
      end # context "#{i} files" do
    end # 10.times do |i|
  end # describe '#mopen' do
end # describe File do
