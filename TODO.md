# TODO

## Things to delete

 * Remove the :using thing in MTs or Links that we used to have to alias things...
 * revise the complexity of generating the contexts all over the place...maybe we can pass down something we already have? ...
 * instrumentation of instrument 'praxis.blueprint.render' ...might slow things down (maybe only on top?)
 * revise blueprint caching...as it must be dependent on fields...not just object id (or remove?)
 * remove decorators from blueprints
 * views (just use a sensible default view of just simple types?)
 * make handlers hang from a singleton (and possibly get rid of xml encoding as well)
 * remove app instances?
 * remove collection summary things...
 * required_if ?... and that conditional dependency thing...?
 * simplify or change examples? ...maybe get rid of randexp.
 * get rid of doc browser in lieu to OAPI and redoc
 * traits? ... we still use them...
 * NOTE: make sure the types we use only expose the json-schema types...no longer things like Hash/Struct/Symbol ...(that might be good only for coding/implementation, not for documentation)
 * Plugins? ... maybe leave them out for the moment?
 * change errors to be machine readable
 * change naming of resource definition to endpoint definition
 * In blueprints...should we autoload? there are a lot of requires ... (for things that might not be used?)

 ## DONE
 * remove links and link_builder
 * remove xml handlers for parsing and rendering. (same for url-encoding) -- (which would allow nil-setting things)
* remove route aliases, named routes...and primary route concepts


 NOTES:
 APIGeneralInfo: consumes and produces (make that the default if it isn't...)
 maybe remove Praxis::Handlers::WWWForm AND  Praxis::Handlers::XML ? or stash them away as examples...

