# coding: utf-8
#
#http://mixi.jp/view_bbs.pl?id=63654902&comment_count=57&comm_id=726
#
#52 2011年08月21日 15:57
#
#    otn
#        私がなんとかスマートに書きたいのは、たくさんのファイルを使うとき。
#
#        open("AAA") do |f1| open("BBB") do |f2| open("CCC","w") do |f3|
#        ～～～～～
#        end; end; end
#
#        を、
#
#        open_multi("AAA","BBB",["CCC","w"]) do |f1,f2,f3|
#        ～～～～～
#        end
#
#        みたいに書けないかなと。
#
class File
  def self.mopen_with(fnames, hundlers, block)
    "fnames:#{fnames.inspect}, hundlers:#{hundlers.inspect}.\n".display if $VERBOSE
    if fnames.size == 0 then
      block.call *hundlers
    else# if fnames.size == 0
      self.open(*(fnames.shift)) do |f|
        mopen_with fnames, hundlers << f, block
      end # self.open(*(fnames.shift)) do |f|
    end # if fnames.size == 0
  end # def self.mopen_with(fnames, hundlers, block)
  private_class_method :mopen_with

  def self.mopen(*fnames, &block)
    mopen_with fnames, [], block
  end # def self.mopen(*fnames)
end # class File

def spec_mopen
  describe File do
    subject{ File }
    it{ should be_true }
    it{ should respond_to(:mopen) }

    describe '.mopen' do
      it 'with no block should not raise LocalJumpError: no block given' do
        lambda{ subject.mopen }.should_not \
          raise_error(LocalJumpError, 'no block given')
      end # it 'with no block should not raise LocalJumpError: no block given'

      it 'with no arguments should not raise ArgumentError' do
        lambda{ subject.mopen }.should_not \
          raise_error(ArgumentError, /wrong number of arguments/)
      end # it 'with no arguments should not raise ArgumentError' do

      it{ lambda{ subject.mopen{} }.should_not raise_error }

      context 'implementaion matters' do
        it 'with no block should raise NoMethodError for nil' do
          lambda{ subject.mopen }.should \
            raise_error(NoMethodError, /for nil:NilClass/)
        end # it 'with no block should raise NoMethodError for nil' do
      end # context 'implementaion matters' do

      context 'one file' do
        it 'should not raise error and receive file name' do
          File.should_receive(:open).with('file_0')
          lambda{ File.mopen('file_0'){ |h| }}.should_not raise_error
        end # it 'should not rase error and receive file name' do

RSpec::Matchers.define :be_open do
  match do |actual|
    `lsof #{actual}`.split("\n").size == 2
  end # match do |actual|
end # RSpec::Matchers.define :be_open do
RSpec::Matchers.define :be_closed do
  match do |actual|
    `lsof #{actual}` == ''
  end # match do |actual|
end # RSpec::Matchers.define :be_closed do

        require 'tempfile'
        around(:each) do |example|
          temp = Tempfile.new 'mopen_spec'
          @fname = temp.path
          temp.close false
          example.run
          temp.close true
        end # around(:each) do |example|

        it 'and should close this file' do 
          @fname.should be_closed
          lambda do
            File.mopen(@fname){ @fname.should be_open }
          end.should_not raise_error
          @fname.should be_closed
        end # it 'and should close this file' do 

        it 'with "w" and should recceive file name and mode' do
          File.should_receive(:open).with('file_1', 'w')
          lambda{ File.mopen(['file_1', 'w']){ |h| }}.should_not raise_error
        end # it 'with "w" and should recceive file name and mode' do

        it 'with "w" and should wright some' do
          @fname.should be_closed
          lambda do
            File.mopen([@fname, 'w']) do |f|
              @fname.should be_open
              Time.now.display f
            end # File.mopen([@fname, 'w']) do |f|
          end.should_not raise_error
          @fname.should be_closed
        end # it 'with "w" and should wright some' do

        it ', should wright, and should read' do 
          str = Time.now.to_s
          lambda do
            File.mopen([@fname, 'w']){ |f| str.display f }
            @fname.should be_closed
            File.mopen(@fname){ |f| f.read.should == str }
          end.should_not raise_error
        end # it ', wright, and read' do 
      end # context 'one file' do

      context 'two files' do
        around(:each) do |example|
          temps = [Tempfile.open('mopen_spec'), Tempfile.open('mopen_spec')]
          @fnames = temps.map{ |t| t.path }
          temps.each{ |t| t.close false }
          example.run
          temps.each{ |t| t.close true }
        end # around(:each) do |example|

        it 'should be open and should be closed' do
          @fnames.each{ |f| f.should be_closed }
          lambda do
            File.mopen(@fnames[0], [@fnames[1], 'a']) do
              @fnames.each{ |f| f.should be_open }
            end # File.mopen(fnames[0], [fnames[1], 'a']) do
          end.should_not raise_error
          @fnames.each{ |f| f.should be_closed }
        end # it 'should be open and should be closed' do

        it 'should be closed when anything raised' do
          lambda do
            File.mopen([@fnames[0], 'r'], [@fnames[1], 'w']) do
              @fnames.each{ |f| f.should be_open }
              raise 'anything'
            end # File.mopen([@fnames[0], 'r'], [@fnames[1], 'w']) do
          end.should raise_error(RuntimeError, 'anything')
          @fnames.each{ |f| f.should be_closed }
        end # it 'should be closed when anything raised' do
      end # context 'two files' do

      it 'four files and should be closed when anything raised' do
        temps = [
          Tempfile.open('mopen_spec'), 
          Tempfile.open('mopen_spec'),
          Tempfile.open('mopen_spec'),
          Tempfile.open('mopen_spec'),
        ]
        fnames = temps.map{ |t| t.path }
        temps.each{ |t| t.close false }

        fnames.each{ |f| f.should be_closed }
        lambda do
          File.mopen(*fnames) do
            fnames.each{ |f| f.should be_open }
            raise 'anything'
          end # File.mopen(*fnames) do
        end.should raise_error(RuntimeError, 'anything')
        fnames.each{ |f| f.should be_closed }

        temps.each{ |t| t.close true }
      end # it 'four files and should be closed when anything raised' do
    end # describe '.mopen' do

    context 'implementaion matters' do
      it{ should_not respond_to(:mopen_with) }

      it do 
        lambda{ subject.mopen_with }.should \
          raise_error(NoMethodError, /private method/) 
      end # it do 

      it do
        lambda{ subject.mopen_with }.should_not \
          raise_error(ArgumentError, /wrong number of arguments/)
      end # it do
    end # context 'implementaion matters' do
  end # describe File do
end # def spec_mopen

case $PROGRAM_NAME
  when __FILE__ then
  when /rspec\z/ then
    #$VERBOSE = true
    spec_mopen
  else
end #case $PROGRAM_NAME
