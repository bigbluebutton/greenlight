# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingOption, type: :model do
  describe 'validations' do
    it { is_expected.to have_many(:room_meeting_options).dependent(:restrict_with_exception) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'scopes' do
    let(:public_option_names) { %w[bbbOption1 bbbOption2 glOption1 glOption2] }
    let(:private_option_names) { %w[privatePW meta_option] }
    let(:bbb_option_names) { %w[bbbOption1 bbbOption2 privatePW meta_option] }
    let(:gl_option_names) { %w[glOption1 glOption2] }
    let(:password_option_names) { %w[privatePW] }

    before do
      public_option_names.each { |name| create :meeting_option, name: }
      private_option_names.each { |name| create :meeting_option, name: }
    end

    describe '#gl_options' do
      it 'returns all meeting options with a "gl" prefix' do
        gl_option_names_from_scope = described_class.gl_options.pluck :name
        expect(gl_option_names - gl_option_names_from_scope).to be_empty
      end
    end

    describe '#bbb_options' do
      it 'returns all meeting options without a "gl" prefix' do
        bbb_option_names_from_scope = described_class.bbb_options.pluck :name
        expect(bbb_option_names - bbb_option_names_from_scope).to be_empty
      end
    end

    describe '#password_options' do
      it 'returns all meeting options having any "PW" substring' do
        password_option_names_from_scope = described_class.password_options.pluck :name
        expect(password_option_names - password_option_names_from_scope).to be_empty
      end
    end

    describe '#public_options' do
      it 'returns all meeting options without any "PW" substring or "meta" prefix' do
        public_option_names_from_scope = described_class.public_options.pluck :name
        expect(public_option_names - public_option_names_from_scope).to be_empty
      end
    end
  end

  describe 'class methods' do
    describe 'public options' do
      let(:public_option_names) { %w[option option1 option2] }
      let(:public_option_names_ids) { public_option_names.each_with_index.to_a }
      let(:public_options) { public_option_names_ids.map { |name, id| { id:, name: } } }

      before { allow(described_class).to receive(:public_options).and_return public_options }

      describe '#public_option_names' do
        it 'calls public_options scope and returns an array of public meeting option names' do
          expect(described_class).to receive(:public_options)
          expect(described_class.public_option_names - public_option_names).to be_empty
        end
      end

      describe '#public_option_names_ids' do
        it 'calls public_options scope and returns a 2D array of vecotrs of public meeting option ids and names' do
          expect(described_class).to receive(:public_options)
          expect(described_class.public_option_names_ids - public_option_names_ids).to be_empty
        end
      end
    end

    describe 'password options' do
      let(:password_options) do
        password_option_names = %w[secretPW privatePW]
        password_option_names_ids = password_option_names.each_with_index.to_a
        password_option_names_ids.map { |name, id| { id:, name: } }
      end
      let(:password_option_ids) { password_options.pluck :id }

      before { allow(described_class).to receive(:password_options).and_return password_options }

      describe '#password_options_ids' do
        it 'calls private_option scope and returns an array of the ids of all password options' do
          expect(described_class).to receive(:password_options)
          expect(described_class.password_option_ids - password_option_ids).to be_empty
        end
      end
    end
  end
end
