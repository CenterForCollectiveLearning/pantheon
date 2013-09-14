// TODO: How do you change this?

Router.map(function() {
    this.route('observatory',
        {path: '/observatory',
        before: [
            function() {
                this.redirect('/' + Session.get('vizType') + '/' + 
                    Session.get('vizMode') + '/' +
                    Session.get('ent1') + '/' +
                    Session.get('ent2') + '/' +                    
                    Session.get('from') + '/' +
                    Session.get('to') + '/' +
                    Session.get('langs'));
            }
        ]}
    );

    this.route('observatory',
        {path: '/',
        before: [
            function() {
                this.redirect('/' + Session.get('vizType') + '/' + 
                    Session.get('vizMode') + '/' +
                    Session.get('ent1') + '/' +
                    Session.get('ent2') + '/' +
                    Session.get('from') + '/' +
                    Session.get('to') + '/' +
                    Session.get('langs'));
            }
        ]}
    );

    this.route('observatory', {
        path: '/:vizType/:vizMode/:ent1/:ent2/:from/:to/:langs',
        data: function() { 
            Session.set('vizType', this.params.vizType); 
            Session.set('vizMode', this.params.vizMode); 
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
    {   'nav':
            { to: 'nav'},
        'footer':
        {   to: 'footer' }
    },
  loadingTemplate: 'spinner'
});
