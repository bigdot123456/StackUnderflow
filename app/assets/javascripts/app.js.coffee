this.Underflow = {}
$ ->
  Underflow.question = new Question
  Underflow.question.answers = []
  Underflow.question.comments = []

  $(".answers .answer").each((i, e) ->
    answer = new Answer(e.id)
    answer.comments = []
    answer.$el.find(".comment").each((i, e) ->
      answer.comments.push(new Comment(e.id))
    )
    Underflow.question.answers.push(answer)
  )

  $(".question .comment").each((i, e) ->
    Underflow.question.comments.push(new Comment(e.id))
  )

#      QUESTION
class Question
  constructor: () ->
    this.$el = $(".question")
    this.$body = this.$el.find(".question-body")
    this.$title = $("#question-title h1")
    this.$commentBtn = this.$el.find(".comment-question")
    this.$commentForm = this.$el.find(".comment-question-form")
    this.$commentsWrapper = this.$el.find(".comments-wrapper")
    this.$comments = this.$commentsWrapper.find(".comments")
    this.$answers = $(".answers")
    this.$answerForm = $("#new-answer-form")
    this.$answersCounter = $("#answers-counter")
    this.answersCounter = this.$answersCounter.data("counter")

    this.bind()
    this.setAjaxHooks()

  bind: () ->
    that = this
    this.$commentBtn.click((e) ->
      e.preventDefault()
      that.toggleCommentForm()
    )

  setAjaxHooks: () ->
    that = this
    this.$answerForm.on "ajax:success", (e, data, status, xhr) ->
      that.addAnswer(xhr.responseJSON)

    this.$answerForm.on "ajax:error", (e, xhr, status) ->
      that.renderAnswerErrors(xhr.responseJSON)

  edit: (form) ->
    this.$body.html(form)

  setTitle: (title) ->
    this.$title.text(title)

  toggleCommentForm: () ->
    this.$commentForm.slideToggle()


  addComment: (comment) ->
    if (this.$comments.length == 0 || this.$comments.find(".comment").length == 0)
      this.$comments = $("<ul class='comments'></ul>").appendTo(this.$commentsWrapper)
    this.$comments.append(comment)
    this.toggleCommentForm()
    this.clearCommentForm()

  removeComment: (commentId) ->
    this.$comments.find("#comment_#{commentId}").remove()
    if (this.$comments.is(":empty"))
      this.$comments.remove()

  editComment: (comment) ->

  renderCommentForm: (form) ->
    this.$commentForm.html(form)

  clearCommentForm: () ->
    this.$commentForm.find("textarea").val("")
    this.$commentForm.find(".alert-danger").remove()
    this.$commentForm.find(".has-error").removeClass("has-error").find(".help-block").remove()

  addAnswer: (answer) ->
    this.$answers.append(HandlebarsTemplates["answer"](answer))
    this.increaseAnswersCounter()
    this.answers.push(new Answer($(answer).attr("id")))
    this.clearAnswerForm()

  renderAnswerErrors: (response) ->
    this.clearAnswerFormErrors()
    this.$answerForm.prepend("<div class='alert alert-danger'>Please review the problems below:</div>")
    for field, error of response
      field = this.$answerForm.find(".form-control#answer_#{field}")
      formGroup = field.parents(".form-group").addClass("has-error")
      formGroup.append("<span class='help-block error'>#{error[0]}</a>")

  clearAnswerFormErrors: () ->
    this.$answerForm.find(".alert.alert-danger").remove()
    formGroup = this.$answerForm.find(".has-error")
    formGroup.find(".help-block.error").remove()
    formGroup.removeClass("has-error")

  clearAnswerForm: () ->
    this.$answerForm.find("textarea").val("")
    this.$answerForm.find(".alert-danger").remove()
    this.$answerForm.find(".has-error").removeClass("has-error").find(".help-block").remove()

  removeAnswer: (answerId) ->
    this.$answers.find("#answer_#{answerId}").remove()
    this.decreaseAnswersCounter()

  renderAnswerForm: (form) ->
    this.$answerForm.html(form)

  increaseAnswersCounter: () ->
    this.answersCounter++
    this.renderAnswersCounter()

  decreaseAnswersCounter: () ->
    this.answersCounter--
    this.renderAnswersCounter()

  renderAnswersCounter: () ->
    answerText = if (this.answersCounter > 1 || this.answersCounter == 0) then "Answers" else "Answer"
    this.$answersCounter.text(this.answersCounter + " " + answerText)

  answerById: (id) ->
    for answer in this.answers
      return answer if answer.id() == "answer_#{id}"
    return null

  commentById: (id) ->
    for comment in this.comments
      return comment if comment.id() == "comment_#{id}"
    return null


#     ANSWER
class Answer
  constructor: (@answer_id) ->
    this.$el = $("##{answer_id}")
    this.$body = this.$el.find(".answer-body")
    this.$commentBtn = this.$el.find(".comment-answer")
    this.$commentForm = this.$el.find(".comment-answer-form")
    this.$commentsWrapper = this.$el.find(".comments-wrapper")
    this.$comments = this.$commentsWrapper.find(".comments")

    this.binds()
    this.setAjaxHooks()

  id: () ->
    @answer_id

  binds: () ->
    that = this
    this.$commentBtn.click((e) ->
      e.preventDefault()
      that.toggleCommentForm()
    )

  setAjaxHooks: () ->
    that = this
    this.$el.on "ajax:success", "form.edit_answer", (e, data, status, xhr) ->
      that.$el.replaceWith(HandlebarsTemplates["answer"](xhr.responseJSON))

    this.$el.on "ajax:error", "form.edit_answer", (e, xhr, status) ->
      console.log "ALARM!!!"
      console.log xhr
      that.renderFormErrors(this, xhr.responseJSON)

  renderFormErrors: (form, response) ->
    $form = $(form)
    this.clearFormErrors(form)
    $form.prepend("<div class='alert alert-danger'>Please review the problems below:</div>")
    console.log typeof response
    for field, error of response
      field = $form.find(".form-control#answer_#{field}")
      formGroup = field.parents(".form-group").addClass("has-error")
      formGroup.append("<span class='help-block error'>#{error[0]}</a>")

  clearFormErrors: (form) ->
    $form = $(form)
    $form.find(".alert.alert-danger").remove()
    formGroup = $form.find(".has-error")
    formGroup.find(".help-block.error").remove()
    formGroup.removeClass("has-error")

  toggleCommentForm: () ->
    this.$commentForm.slideToggle()


  addComment: (comment) ->
    if (this.$comments.length == 0 || this.$comments.find(".comment").length == 0)
      this.$comments = $("<ul class='comments'></ul>").appendTo(this.$commentsWrapper)
    this.$comments.append(comment)
    this.toggleCommentForm()
    this.clearCommentForm()

  removeComment: (commentId) ->
    this.$comments.find("#comment_#{commentId}").remove()
    if (this.$comments.is(":empty"))
      this.$comments.remove()

  renderCommentForm: (form) ->
    this.$commentForm.html(form)

  clearCommentForm: () ->
    this.$commentForm.find("textarea").val("")
    this.$commentForm.find(".alert-danger").remove()
    this.$commentForm.find(".has-error").removeClass("has-error").find(".help-block").remove()

  edit: (form) ->
    this.$body.html(form)

  commentById: (id) ->
    for comment in this.comments
      return comment if comment.id() == "comment_#{id}"
    return null


#     COMMENT
class Comment
  constructor: (@commentId) ->
    this.$el= $("##{commentId}")
    this.$body = this.$el.find(".comment-body")

  id: ->
    @commentId

  edit: (comment) ->
    this.$el.html(comment)
