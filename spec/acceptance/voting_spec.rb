require 'rails_helper'
require 'capybara/rails'
require 'support/pages/movie_list'
require 'support/pages/movie_new'
require 'support/with_user'

RSpec.describe 'vote on movies', type: :feature do

  let(:page) { Pages::MovieList.new }

  before do
    author = User.create(
      uid:  'null|12345',
      name: 'Bob',
      email: 'bob@example.com'
    )
    Movie.create(
      title:        'Empire strikes back',
      description:  'Who\'s scruffy-looking?',
      date:         '1980-05-21',
      user:         author
    )
    author_without_email = User.create(
      uid:  'null|99999',
      name: 'Jack'
    )
    Movie.create(
      title:        'The Force Awakens',
      description:  'Chewie, we\'re home!',
      date:         '2015-12-18',
      user:         author_without_email
    )
    Sidekiq::Worker.clear_all
  end

  context 'when logged out' do
    it 'cannot vote' do
      page.open
      expect {
        page.like('Empire strikes back')
      }.to raise_error(Capybara::ElementNotFound)
    end
  end

  context 'when logged in' do
    with_logged_in_user

    before { page.open }

    it 'can like' do
      page.like('Empire strikes back')
      expect(page).to have_vote_message
    end

    it 'can hate' do
      page.hate('Empire strikes back')
      expect(page).to have_vote_message
    end

    it 'can unlike' do
      page.like('Empire strikes back')
      page.unlike('Empire strikes back')
      expect(page).to have_unvote_message
    end

    it 'can unhate' do
      page.hate('Empire strikes back')
      page.unhate('Empire strikes back')
      expect(page).to have_unvote_message
    end

    it 'cannot like twice' do
      expect {
        2.times { page.like('Empire strikes back') }
      }.to raise_error(Capybara::ElementNotFound)
    end

    it 'cannot like own movies' do
      Pages::MovieNew.new.open.submit(
        title:       'The Party',
        date:        '1969-08-13',
        description: 'Birdy nom nom')
      page.open
      expect {
        page.like('The Party')
      }.to raise_error(Capybara::ElementNotFound)
    end

    context 'author of the movie submission has an email address' do
      it 'doesn\'n send an email directly if a movie is liked' do
        expect { page.like('Empire strikes back') }.to_not(
          change{Sidekiq::Extensions::DelayedMailer.jobs.size }
        )
      end

      it 'sends an email if a movie is hated' do
        expect { page.hate('Empire strikes back') }.to_not(
          change{Sidekiq::Extensions::DelayedMailer.jobs.size }
        )
      end
    end

    context 'author of the movie submission doesn\'t have an email address' do

      it 'doesn\'t send an email if a movie is liked' do
        expect { page.like('The Force Awakens') }.to_not(
          change(Sidekiq::Extensions::DelayedMailer.jobs, :size)
        )
      end
    end
  end

end
