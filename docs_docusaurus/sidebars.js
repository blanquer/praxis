module.exports = {
  mainSidebar: [
    {
      type: 'category',
      label: 'Intro',
      items: [
        'intro/intro',
        'intro/installation'
      ]
    },
    // {
    //   type: 'doc',
    //   id: 'gettingStarted/gettingStarted'
    // },
    {
      type: 'category',
      label: 'Getting Started',
      collapsed: false,
      items: [
        'gettingStarted/intro', 
        'gettingStarted/gettingStarted',
        'gettingStarted/settingUpOurDB',
        'gettingStarted/implementingOurAPI',
        'gettingStarted/buildingFiltering',
        'gettingStarted/buildingCRUD',                
      ]
    },    
    {
      type: 'category',
      label: 'Other things',
      collapsed: false,
      items: ['doc2', 'doc3']
    }
  ]  
};



// otherSidebar: {
//   Foobar: ['doc3'],
//   Intro: ['intro/intro'],
//   GettingStarted: ['gettingStarted/gettingStarted', 'doc2', 'doc3'],
//   DesigningApis: ['doc1', 'doc2', 'doc3'],
//   ImplementingApis: ['doc1', 'doc2', 'doc3'],
//   Internals: ['mdx'],
// },