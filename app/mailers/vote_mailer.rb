class VoteMailer < ActionMailer::Base
  default from: "info@movierama.dev"

  def notification_email(movie_id, liked_by_user_id, type)
    @movie = Movie[movie_id]
    @user =  User[liked_by_user_id]
    mail(to: @movie.user.email, subject: 'Your movie was liked!')
  end
end
