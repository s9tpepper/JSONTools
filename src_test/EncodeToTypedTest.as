package {

import ab.fl.utils.json.JSON;

import helpers.vo.TypedVO;

import org.flexunit.Assert;

public class EncodeToTypedTest {

    private var strongTypedVO:TypedVO;

    [Before]
    public function setup():void {
        strongTypedVO = typedVO;
        ab.fl.utils.json.JSON.registerClass("TypedVO", TypedVO);
    }

    [After]
    public function tearDown():void {
        strongTypedVO = null;
    }

    [Test]
    public function int_value_of_1_should_encode_to_1():void {
        var json:String = ab.fl.utils.json.JSON.encodeToTyped(strongTypedVO);
        var index:int = json.search(/aInt/i) + 6;
        Assert.assertEquals(1, json.substr(index, 1));
    }

    [Test]
    public function int_value_of_0_should_encode_to_0():void {
        strongTypedVO.aInt = 0;
        var json:String = ab.fl.utils.json.JSON.encodeToTyped(strongTypedVO);
        var index:int = json.search(/aInt/i) + 6;
        Assert.assertEquals(0, json.substr(index, 1));
    }

    [Test]
    public function uint_value_of_1_should_encode_to_1():void {
        var json:String = ab.fl.utils.json.JSON.encodeToTyped(strongTypedVO);
        var index:int = json.search(/aUint/i) + 7;
        Assert.assertEquals(1, json.substr(index, 1));
    }

    [Test]
    public function uint_value_of_0_should_encode_to_0():void {
        strongTypedVO.aUint = 0;
        var json:String = ab.fl.utils.json.JSON.encodeToTyped(strongTypedVO);
        var index:int = json.search(/aUint/i) + 7;
        Assert.assertEquals(0, json.substr(index, 1));
    }

    [Test]
    public function number_value_of_1_should_encode_to_1():void {
        var json:String = ab.fl.utils.json.JSON.encodeToTyped(strongTypedVO);
        var index:int = json.search(/aNumber/i) + 9;
        Assert.assertEquals(1, json.substr(index, 1));
    }

    [Test]
    public function number_value_of_0_should_encode_to_0():void {
        strongTypedVO.aNumber = 0;
        var json:String = ab.fl.utils.json.JSON.encodeToTyped(strongTypedVO);
        var index:int = json.search(/aNumber/i) + 9;
        Assert.assertEquals(0, json.substr(index, 1));
    }

    [Test]
    public function string_value_of_a_should_encode_to_a():void {
        var json:String = ab.fl.utils.json.JSON.encodeToTyped(strongTypedVO);
        var index:int = json.search(/aString/i) + 10;
        Assert.assertEquals("a", json.substr(index, 1));
    }

    [Test]
    public function empty_string_value_should_encode_to_empty_string():void {
        strongTypedVO.aString = "";
        var json:String = ab.fl.utils.json.JSON.encodeToTyped(strongTypedVO);
        var index:int = json.search(/aString/i) + 10;
        Assert.assertEquals('"', json.substr(index, 1));
    }

    [Test]
    public function boolean_value_of_true_should_encode_to_true():void {
        var json:String = ab.fl.utils.json.JSON.encodeToTyped(strongTypedVO);
        var index:int = json.search(/aBoolean/i) + 10;
        Assert.assertEquals("true", json.substr(index, 4));
    }

    [Test]
    public function boolean_value_of_false_should_encode_to_false():void {
        strongTypedVO.aBoolean = false;
        var json:String = ab.fl.utils.json.JSON.encodeToTyped(strongTypedVO);
        var index:int = json.search(/aBoolean/i) + 10;
        Assert.assertEquals("false", json.substr(index, 5));
    }

    private function get typedVO():TypedVO {
        var _typedVO:TypedVO = new TypedVO();
        _typedVO.aInt = 1;
        _typedVO.aUint = 1;
        _typedVO.aNumber = 1;
        _typedVO.aString = "a";
        _typedVO.aBoolean = true;
        return _typedVO;
    }
}
}
