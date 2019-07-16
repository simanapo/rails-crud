# app\assets\javascripts\admin\companies.coffee

class CompaniesController

  # JSの一例

  index: ->
    self = this
    # エラー表示
    show_error_message = (element, error_messages) ->
      element.addClass 'error_block'
      element.find('p').remove()

      for error_message in error_messages
        element.append '<p>' + error_message.message + '</p>'
      return

    ##
    # エラー表示(remodal ver)
    ##
    show_error_modal = (error, id = 'remodal-error') ->
      if $.isArray(error)
        error_messages = error
      else if error.responseJSON && error.responseJSON.errors
        error_messages = error.responseJSON.errors
      else
        error_messages = []

      $element = $('[data-remodal-id="' + id + '"]')

      if error_messages.length > 0
        $element.find('.modal_text').empty()
        for error_message in error_messages
          $element.find('.modal_text').append '<p>' + error_message.message + '</p>'

      $element.remodal().open()

      return

    # 会社更新 確認
    $('[data-method="update_confirm"]')
      .on 'ajax:success', (event, data, status, xhr)->
        data = $.parseJSON(xhr.responseText);
        modal = $('[data-remodal-id="modal-edit-confirm"]')
        modal.remodal().open()
        modal.find('form').attr('action', self.path + '/' + data.id)
        $('[data-remodal-id="modal-edit-confirm"]').remodal().open()
        $('[data-remodal-id="modal-edit-confirm"]').find('#id').val(data.id)
        $('[data-remodal-id="modal-edit-confirm"]').find('#updated_at').val(data.updated_at)
        $('[data-remodal-id="modal-edit-confirm"]').find('#company_name').val(data.company_name)
        $('[data-remodal-id="modal-edit-confirm"]').find('#company_name_kana').val(data.company_name_kana)
        return
      .on 'ajax:error', (event, xhr, status, error)->
        data = $.parseJSON(xhr.responseText);
        show_error_message $(@).find('[data-method="update_error_message"]'), data.errors
        return

    # 会社更新 実行
    $('[data-method="update"]')
      .on 'ajax:success', (event, data, status, xhr)->
        data = $.parseJSON(xhr.responseText);
        $('[data-remodal-id="modal-edit-complete"]').remodal().open()
        return
      .on 'ajax:error', (event, xhr, status, error)->
        show_error_modal(xhr)
        return

    # 更新完了モーダルを閉じる
    $('[data-method="update_complete"]')
      .on 'click', ->
        $('[data-remodal-id="modal-edit-complete"]').remodal().close()
        Turbolinks.visit(location.toString())
        return

    return

this.Application.companies = new CompaniesController