require 'rails_helper'

RSpec.describe Question, :type => :model do

	it { is_expected.to have_many :answers }
	it { is_expected.to belong_to :user }

	it { is_expected.to validate_presence_of :title }
	it { is_expected.to validate_presence_of :body }
	it { is_expected.to ensure_length_of(:title).is_at_least(5).is_at_most(512) }
	it { is_expected.to ensure_length_of(:body).is_at_least(10).is_at_most(5000) }

	it { is_expected.to respond_to(:best_answer) }

end