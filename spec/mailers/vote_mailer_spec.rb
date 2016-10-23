require 'rails_helper'

RSpec.describe VoteMailer, type: :mailer do

  before do
    @author = User.create(
      uid:   'null|12345',
      name:  'Bob',
      email: 'bob@example.com'
    )
    @user = User.create(
      uid:   'null|98765',
      name:  'Alice',
      email: 'alice@example.com'
    )
    @movie = Movie.create(
      title:        'Empire strikes back',
      description:  'Who\'s scruffy-looking?',
      date:         '1980-05-21',
      user:         @author
    )

  end

  describe 'notification_email' do
    context 'movie is liked' do
      let(:mail) { VoteMailer.notification_email(@movie.id, @user.id, :like).deliver }

      it 'says in the subject that the movie was liked' do
        expect(mail.subject).to match %r(was liked)
      end

      it 'says in the body which movie was liked' do
        expect(mail.body.encoded).to match %r(#{@movie.title})
      end

      it 'says in the body which user liked this movie' do
        expect(mail.body.encoded).to match %r(liked by #{@user.name})
      end

      it 'sends the mail only to the author of the movie submission' do
        expect(mail.to.count).to be(1)
        expect(mail.to.first).to eq @author.email
      end

      it 'sends the mail from `info@movierama.dev`' do
        expect(mail.from.count).to be(1)
        expect(mail.from.first).to eq 'info@movierama.dev'
      end
    end

    context 'movie is hated' do
      let(:mail) { VoteMailer.notification_email(@movie.id, @user.id, :hate).deliver }

      it 'says in the subject that the movie was hated' do
        expect(mail.subject).to match %r(hated your movie!)
      end

      it 'says in the body which movie was hated' do
        expect(mail.body.encoded).to match %r(#{@movie.title})
      end

      it 'says in the body which user hated this movie' do
        expect(mail.body.encoded).to match %r(hated by #{@user.name})
      end

      it 'sends the mail only to the author of the movie submission' do
        expect(mail.to.count).to be(1)
        expect(mail.to.first).to eq @author.email
      end

      it 'sends the mail from `info@movierama.dev`' do
        expect(mail.from.count).to be(1)
        expect(mail.from.first).to eq 'info@movierama.dev'
      end
    end
  end
end
