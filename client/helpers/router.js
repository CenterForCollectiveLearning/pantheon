
Router.map(function() {
    this.route('observatory',
        {path: '/'}  // :vizType/:ent1/:ent2/:from/:to/:langs'}
    );
    this.route('observatory', {
        path: '/:vizType',
        data: function() { 
            Session.set('vizType', this.params.vizType); 
        }}
    );
    this.route('observatory', {
        path: '/:vizType/:ent1/:ent2',
        data: function() { 
            Session.set('vizType', this.params.vizType); 
            Session.set('ent1', this.params.ent1);  
            Session.set('ent2', this.params.ent2);  
        }}
    );

    this.route('observatory', {
        path: '/:vizType/:ent1/:ent2/:from/:to/:langs',
        data: function() { 
            Session.set('vizType', this.params.vizType); 
            Session.set('ent1', this.params.ent1);  
            Session.set('ent2', this.params.ent2);  
            Session.set('from', this.params.from); 
            Session.set('to', this.params.to);  
            Session.set('langs', this.params.langs);  
        }}
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
