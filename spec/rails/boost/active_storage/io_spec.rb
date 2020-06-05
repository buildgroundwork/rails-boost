# frozen_string_literal: true

require "rails/boost"
require "rails/boost/active_storage/io"
require "rspec/common/extensions/active_storage/service/memory"
require "active_support/all"

describe Rails::Boost::ActiveStorage::IO do
  let(:io) { described_class.new(blob) }
  let(:blob) { double(:blob, service: service, key: key) }
  let(:service) { ActiveStorage::Service::MemoryService.new }
  let(:key) { "wibble" }
  let(:content) { "Now is the time" }

  before { service.override(key, content) }

  describe "#read" do
    subject { io.read(length) }

    # Reads length bytes from the I/O stream.
    context "when at the beginning" do
      before { expect(io.pos).to be_zero }

      context "with a length shorter than the remaining content" do
        let(:length) { 2 }
        it { should == content[0...length] }
      end

      context "with a length longer than the remaining content" do
        let(:length) { 100 }
        it { should == content }
      end
    end

    context "after pos is set" do
      let(:pos) { 1 }
      before { io.pos = pos }

      context "with a length shorter than the remaining content" do
        let(:length) { 1 }
        it { should == content[pos] }
      end

      context "with a length longer than the remaining content" do
        let(:length) { 100 }
        it { should == content[pos..] }
      end
    end

    context "after a previous read" do
      let(:pos) { 1 }
      before { io.read(pos) }

      context "with a length shorter than the remaining content" do
        let(:length) { 1 }
        it { should == content[pos] }
      end

      context "with a length longer than the remaining content" do
        let(:length) { 100 }
        it { should == content[pos..] }
      end
    end

    context "when at EOF" do
      before { io.read(1_000) }

      context "when length is non-zero" do
        let(:length) { 1 }
        it { should be_nil }
      end

      context "when length is zero" do
        let(:length) { 0 }
        it { should == "" }
      end
    end

    context "with a negative length" do
      subject { -> { io.read(length) } }
      let(:length) { -1 }
      it { should raise_error(ArgumentError).with_message("negative length -1 given") }
    end

    context "with no length" do
      subject { io.read(length) }
      let(:length) { nil }
      it { should == content }
    end

    context "with length 0" do
      let(:length) { 0 }
      it { should == "" }
    end
  end

  describe "#eof?" do
    subject { io.eof? }

    context "with content remaining" do
      before { io.read(1) }
      it { should_not be_truthy }
    end

    context "with no content remaining" do
      before { io.read(1_000) }
      it { should be_truthy }
    end
  end

  describe "#pos=" do
    subject { -> { io.pos = new_pos } }
    let(:new_pos) { 2 }

    it { should change(io, :pos).to(new_pos) }

    context "when at EOF" do
      before do
        io.read(1_000)
        expect(io).to be_eof
      end

      it { should change(io, :eof?).to(false) }
    end
  end

  describe "#rewind" do
    subject { -> { io.rewind } }
    before { io.read(1_000) }

    it { should change(io, :pos).to be_zero }
    it { should change(io, :eof?).to(false) }
  end
end

