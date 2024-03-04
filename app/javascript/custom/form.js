//= require jquery
$(function () {
  //テキストエリアがアクティブの状態にキーが押されたらイベントを発火
  $("#commentInput").keydown(function (e) {
    //ctrlキーが押されてる状態か判定
    if (event.ctrlKey) {
      //押されたキー（e.keyCode）が13（Enter）か　そしてテキストエリアに何かが入力されているか判定
      if (e.keyCode === 13 && $(this).val()) {
        //フォームを送信
        $("#commentSubmit").submit();
        return false;
      }
    }
  });
});
