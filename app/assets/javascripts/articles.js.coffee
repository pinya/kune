# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  # Delete comment or article
  $(document)
    .on "ajax:success", (evt, data, status, xhr) ->
      $("##{data.model}-#{data.id}").hide('fast')
