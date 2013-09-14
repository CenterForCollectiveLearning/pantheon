
Router.map(function() {
    this.route('observatory',
        {path: '/'} // :vizType/:tradeflow/:ent1/:ent2/:from/:to/:langs'}
    );
    // this.route('observatory'); // TODO: there is probaby a way to make two paths point to the same template
    this.route('vision');
    this.route('ranking');
    this.route('data');
    this.route('faq');
    this.route('people');
    this.route('about');
});

Router.configure({
  layout: 'defaultLayout',
  renderTemplates:
    { 'footer':
        { to: 'footer' }
    }
});
