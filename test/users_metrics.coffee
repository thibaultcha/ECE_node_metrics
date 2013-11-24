{exec} = require 'child_process'
should = require 'should'

describe 'users_metrics', ->
	users = null
	metrics = null
	uMetrics = null

	before (next) ->
		exec "rm -rf #{__dirname}/../db/users-metrics && mkdir #{__dirname}/../db/users-metrics", (err, stdout) ->
			throw err if err
			users = require '../lib/users'
			metrics = require '../lib/metrics'
			uMetrics = require '../lib/users_metrics'
			next()

	describe 'addMetrics()', ->

		it 'should add an existing metric to an existing user', (next) ->
			user =
				email: "add@domain.com"

			met = [
				timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:1234
			,
				timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:5678
			]

			metrics.save 3, met, (err) ->
				next err if err
				users.save user, (err) ->
					next err if err
					uMetrics.addMetrics user, 3, (err) ->
						next err if err	
						uMetrics.getMetrics user, (err, user_metrics) ->
							next err if err
							user_metrics.should.be.an.instanceOf(Array)
							user_metrics.length.should.be.equal 1
							user_metrics[0].id.should.equal 3
							user_metrics[0].metrics.should.be.an.instanceOf(Array)
							user_metrics[0].metrics[0].value.should.be.equal 1234
							next()

		it 'should return an error if user does not exist', (next) ->
			user =
				email: "wrong@domain.com"

			uMetrics.addMetrics user, 0, (err) ->
				err.should.not.be.null
				next()

		it 'should return an error if metric_id does not exist', (next) ->
			user =
				email: "name@domain.com"

			users.save user, (err) ->
				next err if err
				uMetrics.addMetrics user, 9999, (err) ->
					err.should.not.be.null
					next()

	describe 'getMetrics()', ->

		it 'should return an empty array if no metrics for id', (next) ->
			user = 
				email: "get@domain.com"

			users.save user, (err) ->
				next err if err
				uMetrics.getMetrics user, (err, user_metrics) ->
					next err if err
					user_metrics.should.be.an.instanceOf(Array)
					user_metrics.length.should.equal 0
					next()

		it 'should return an error if user does not exist', (next) ->
			user =
				email: "wrong@domain.com"

			uMetrics.getMetrics user, (err) ->
				err.should.not.be.null
				next()

	describe 'removeMetrics()', ->

		it 'should return an error if user does not exist', (next) ->
			user =
				email: "wrong@domain.com"

			uMetrics.removeMetrics user, 1, (err) ->
				err.should.not.be.null
				next()

		it 'should return an error if trying to remove a metrics not attached to user', (next) ->
			user =
				email: "name@domain.com"

			users.save user, (err) ->
				next err if err
				uMetrics.removeMetrics user, 9999, (err) ->
					err.should.not.be.null
					next()

		it 'should remove attached metric to existing user', (next) ->
			user =
				email: "remove@domain.com"

			met = [
				timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:1234
			,
				timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:5678
			]

			users.save user, (err) ->
				next err if err
				metrics.save 1, met, (err) ->
					next err if err
					uMetrics.addMetrics user, 1, (err) ->
						next err if err
						uMetrics.getMetrics user, (err, user_metrics) ->
							next err if err
							user_metrics.should.be.an.instanceOf(Array)
							user_metrics.length.should.equal 1
							user_metrics[0].metrics[0].value.should.equal 1234
							uMetrics.removeMetrics user, 1, (err) ->
								next err if err
								uMetrics.getMetrics user, (err, final_metrics) ->
									next err if err
									final_metrics.length.should.be.equal 0
									next()

	after (next) ->
		exec "rm -rf #{__dirname}/../db/users-metrics", (err, stdout) ->
			next err if err
			next()