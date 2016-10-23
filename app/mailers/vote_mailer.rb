class VoteMailer < ActionMailer::Base
  default from: "info@movierama.dev"

  def notification_email(movie_id, liked_by_user_id, type)
    @movie = Movie[movie_id]
    @user =  User[liked_by_user_id]
    mail(to: @movie.user.email, subject: _subject_for(type),
         template_name: "#{type}_notification")
  end

  private

  def _subject_for(type)
    if type == :like
      'Your movie was liked!'
    elsif type == :hate
      'Oh no! Someone hated your movie!'
    end
  end
end
