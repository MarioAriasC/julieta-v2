local ut = require("utilstest")
local ast = require("ast")
local utils = require("utils")
require("busted.runner")()

describe("A parser", function()
	describe("should parse", function()
		it("let statements", function()
			local tests = {
				{ "let x = 5;", "x", 5 },
				{ "let y = true;", "y", true },
				{ "let foobar = y;", "foobar", "y" },
			}
			ut.forEachTests(tests, 3, function(input, expectedIdentifier, expectedValue)
				local program = ut.createProgram(input)
				ut.countStatements(1, program, assert)
				local statement = ast.program.getStatements(program)[1]
				ut.assertLetStatement(statement, expectedIdentifier, assert)
				local value = ast.letStatement.getValue(statement)
				ut.assertLiteralExpression(value, expectedValue, assert)
			end)
		end)
		it("return statements", function()
			local tests = {
				{ "return 5;", 5 },
				{ "return true;", true },
				{ "return foobar;", "foobar" },
			}
			ut.forEachTests(tests, 2, function(input, expectedIdentifier)
				local program = ut.createProgram(input)
				ut.countStatements(1, program, assert)
				local statement = ast.program.getStatements(program)[1]
				assert.are.same("return", ast.getTokenLiteral(statement))
				ut.assertLiteralExpression(ast.returnStatement.getReturnValue(statement), expectedIdentifier, assert)
			end)
		end)
		it("identifier expression", function()
			local input = "foobar;"
			local program = ut.createProgram(input)
			ut.countStatements(1, program, assert)
			local statement = ast.program.getStatements(program)[1]
			local identifier = ast.expressionStatement.getExpression(statement)
			assert.are.same("foobar", ast.identifier.getValue(identifier))
			assert.are.same("foobar", ast.getTokenLiteral(identifier))
		end)
		it("integer literals", function()
			local input = "5;"
			local program = ut.createProgram(input)
			ut.countStatements(1, program, assert)
			local statement = ast.program.getStatements(program)[1]
			local expression = ast.expressionStatement.getExpression(statement)
			if ast.getClassName(expression) == "IntegerLiteral" then
				assert.are.same(5, ast.literal.getValue(expression))
				assert.are.same("5", ast.getTokenLiteral(expression))
			else
				error(string.format("statement.expression not IntegerLiteral. got=%s", tostring(statement)))
			end
		end)
		it("prefix expression", function()
			local tests = {
				{ "!5;", "!", 5 },
				{ "-15;", "-", 15 },
				{ "!true;", "!", true },
				{ "!false;", "!", false },
			}
			ut.forEachTests(tests, 3, function(input, operator, value)
				local program = ut.createProgram(input)
				ut.countStatements(1, program, assert)
				local statement = ast.program.getStatements(program)[1]
				local expression = ast.expressionStatement.getExpression(statement)
				assert.are.same(operator, ast.prefixExpression.getOperator(expression))
				ut.assertLiteralExpression(ast.prefixExpression.getRight(expression), value, assert)
			end)
		end)
		it("infix expressions", function()
			local tests = {
				{ "5 + 5;", 5, "+", 5 },
				{ "5 - 5;", 5, "-", 5 },
				{ "5 * 5;", 5, "*", 5 },
				{ "5 / 5;", 5, "/", 5 },
				{ "5 > 5;", 5, ">", 5 },
				{ "5 < 5;", 5, "<", 5 },
				{ "5 == 5;", 5, "==", 5 },
				{ "5 != 5;", 5, "!=", 5 },
				{ "true == true", true, "==", true },
				{ "true != false", true, "!=", false },
				{ "false == false", false, "==", false },
			}
			ut.forEachTests(tests, 4, function(input, leftValue, operator, rightValue)
				local program = ut.createProgram(input)
				ut.countStatements(1, program, assert)
				local statement = ast.program.getStatements(program)[1]
				local expression = ast.expressionStatement.getExpression(statement)
				ut.assertInfixExpression(expression, leftValue, operator, rightValue, assert)
			end)
		end)
		it("operator precedence", function()
			local tests = {
				{
					"-a * b",
					"((-a) * b)",
				},
				{
					"!-a",
					"(!(-a))",
				},
				{
					"a + b + c",
					"((a + b) + c)",
				},
				{
					"a + b - c",
					"((a + b) - c)",
				},
				{
					"a * b * c",
					"((a * b) * c)",
				},
				{
					"a * b / c",
					"((a * b) / c)",
				},
				{
					"a + b / c",
					"(a + (b / c))",
				},
				{
					"a + b * c + d / e - f",
					"(((a + (b * c)) + (d / e)) - f)",
				},
				{
					"3 + 4; -5 * 5",
					"(3 + 4)((-5) * 5)",
				},
				{
					"5 > 4 == 3 < 4",
					"((5 > 4) == (3 < 4))",
				},
				{
					"5 < 4 != 3 > 4",
					"((5 < 4) != (3 > 4))",
				},
				{
					"3 + 4 * 5 == 3 * 1 + 4 * 5",
					"((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))",
				},
				{
					"true",
					"true",
				},
				{
					"false",
					"false",
				},
				{
					"3 > 5 == false",
					"((3 > 5) == false)",
				},
				{
					"3 < 5 == true",
					"((3 < 5) == true)",
				},
				{
					"1 + (2 + 3) + 4",
					"((1 + (2 + 3)) + 4)",
				},
				{
					"(5 + 5) * 2",
					"((5 + 5) * 2)",
				},
				{
					"2 / (5 + 5)",
					"(2 / (5 + 5))",
				},
				{
					"(5 + 5) * 2 * (5 + 5)",
					"(((5 + 5) * 2) * (5 + 5))",
				},
				{
					"-(5 + 5)",
					"(-(5 + 5))",
				},
				{
					"!(true == true)",
					"(!(true == true))",
				},
				{
					"a + add(b * c) + d",
					"((a + add((b * c))) + d)",
				},
				{
					"add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))",
					"add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))",
				},
				{
					"add(a + b + c * d / f + g)",
					"add((((a + b) + ((c * d) / f)) + g))",
				},
				{
					"a * [1, 2, 3, 4][b * c] * d",
					"((a * ([1, 2, 3, 4][(b * c)])) * d)",
				},
				{
					"add(a * b[2], b[1], 2 * [1, 2][1])",
					"add((a * (b[2])), (b[1]), (2 * ([1, 2][1])))",
				},
			}
			ut.forEachTests(tests, 2, function(input, expected)
				local program = ut.createProgram(input)
				assert.are.same(expected, ast.toString(program))
			end)
		end)
		it("boolean expression", function()
			local tests = {
				{ "true", true },
				{ "false", false },
			}
			ut.forEachTests(tests, 2, function(input, expected)
				local program = ut.createProgram(input)
				ut.countStatements(1, program, assert)
				local booleanLiteral = ut.getExpression(program)
				assert.are.same(expected, ast.literal.getValue(booleanLiteral))
			end)
		end)

		local function assertIfExpression(input)
			local program = ut.createProgram(input)
			ut.countStatements(1, program, assert)
			local exp = ut.getExpression(program)
			ut.assertInfixExpression(ast.ifExpression.getCondition(exp), "x", "<", "y", assert)
			local consequenseStatements = ast.blockStatement.getStatements(ast.ifExpression.getConsequence(exp))
			assert.are.same(1, utils.len(consequenseStatements))
			local consequence = consequenseStatements[1]
			ut.assertIdentifier(ast.expressionStatement.getExpression(consequence), "x", assert)
			return exp
		end

		it("if expression", function()
			local input = "if (x < y) { x }"
			local exp = assertIfExpression(input)
			assert.are.same(nil, exp.alternative)
		end)
		it("if else expression", function()
			local input = "if (x < y) { x } else { y }"
			local exp = assertIfExpression(input)
			local alternativeStatements = ast.blockStatement.getStatements(ast.ifExpression.getAlternative(exp))
			assert.are.same(1, utils.len(alternativeStatements))
			local alternative = alternativeStatements[1]
			ut.assertIdentifier(ast.expressionStatement.getExpression(alternative), "y", assert)
		end)
	end)
end)
