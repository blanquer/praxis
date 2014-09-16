# praxis changelog

## next

* Avoid loading responses (and templates) lazily as they need to be registered in time
* Fix: app generator's handling of 404. [@magneland](https://github.com/magneland) [Issue #10](https://github.com/rightscale/praxis/issues/10)
* Fix: Getting started doc. [@WilliamSnyders](https://github.com/WilliamSnyders) [Issue #19](https://github.com/rightscale/praxis/issues/19)
* Controller filters can now shortcut the request lifecycle flow by returning a `Response`:
  * If a before filter returns it, both the action and the after filters will be skipped (as well as any remaining filters in the before list)
  * If an after filter returns it, any remaining after filters in the block will be skipped.
  * There is no way for the action result to skip the :after filters.
* Refactored Controller module to properly used ActiveSupprt concerns. [@jasonayre](https://github.com/jasonayre) [Issue #26](https://github.com/rightscale/praxis/issues/26)
* Separated the controller module into a Controller concern and a separable Callbacks concern
* Controller filters (i.e. callbacks) can shortcut request lifecycle by returning a Response object:
  * If a before filter returns it, both the action and the after filters will be skipped (as well as any remaining before filters)
  * If an after filter returns it, any remaining after filters in the block will be skipped.
  * There is no way for the action result to skip the :after filters.
  * Fixes [Issue #21](https://github.com/rightscale/praxis/issues/21)
* Introduced `around` filters using blocks:
	* Around filters can be set wrapping any of the request stages (load, validate, action...) and might apply to only certain actions (i.e. exactly the same as the before/after filters)
  * Therefore they supports the same attributes as `before` and `after` filters. The only difference is that an around filter block will get an extra parameter with the block to call to continue the chain.	
	* See the [Instances](https://github.com/rightscale/praxis/blob/master/spec/spec_app/app/controllers/instances.rb) controller for examples.
* Fix: Change :created response template to take an optiona ‘location’ parameter (instead of a media_type one, since it doesn’t make sense for a 201 type response) [Issue #26](https://github.com/rightscale/praxis/issues/23)

## 0.9 Initial release