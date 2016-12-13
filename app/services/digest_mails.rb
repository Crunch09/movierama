class DigestMails

  def self.run
    vote_counts_by_author = {}
    VoteCounter.all.each do |vote_count|
      author = vote_count.movie.user
      vote_counts_by_author[author.id] ||= {}
      vote_counts_by_author[author.id][vote_count.movie.id] ||= {"like" => 0, "hate" => 0}
      vote_counts_by_author[author.id][vote_count.movie.id][vote_count.type] += 1
    end
    vote_counts_by_author.each do |author_id, movies|
      NotificationMailer.delay.notification_email(author_id, movies)
    end
  end
end
