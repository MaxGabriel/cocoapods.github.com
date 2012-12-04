$(function() {

  /**
   * Provides support for the tab navigation.
   *
   * Each tab is identified by an id in the form `#tab_NAME` which prevents the
   * page to scroll.
   *
   * `#tab-controller`  contains all the anchors associated with the tabs.
   * `.tab-content`     contains the tabs.
   */

  // returns the jQuery anchor associated with the given name.
  //
  function tabAnchorByName(name) {
    // TODO
    // return $('#methods_list a[href=#tab_' + name.replace('#', '') + ']');
    return $('#tab-controller a[href="#tab_' + name.replace('#', '') + '"]');
  }

  // Shows the tab associated to the given name.
  //
  // It takes care of moving the active class from the anchor of the previous
  // selected tab to the new one and of updating the url with the new fragment.
  //
  function selectTabByName(name) {
    $('#tab-controller .active').removeClass('active');
    var tabLink = tabAnchorByName(name);
    tabLink.parent().addClass('active')
    console.log(tabLink)

    tabLink.tab('show');
    document.location.hash = name;
  }

  // Shows the tab associated with the given anchor.
  //
  function selectTab(clickedLink) {
    selectTabByName(clickedLink.attr("href").replace('#tab_', ''));
  }

  //--------------------------------------//

  // Activates the custom behaviour for the Anchors
  //
  $('#tab-controller a.select-tab').click(function (e) {
    e.preventDefault();
    selectTab($(this));
  })

  // TODO: Activates the tab associated with the current section.
  //
  $('#tab-controller h1 a.select-tab').click(function (e) {
    e.preventDefault();
    $('#tab-controller .active').removeClass('active');
    $(this).tab('show');
    document.location.hash = '';
  })

  //--------------------------------------//

  // Shows the tab associated with the current fragment or the description of
  // the sections on page load.
  //
  $(function () {
    var tabLink = tabAnchorByName(document.location.hash);
    if (tabLink.size() == 1) {
      selectTab(tabLink);
    } else {
      // TODO Find a way to specify the default tab
      $('#tab-controller h1 a.select-tab').tab('show');
    }
  });
});
