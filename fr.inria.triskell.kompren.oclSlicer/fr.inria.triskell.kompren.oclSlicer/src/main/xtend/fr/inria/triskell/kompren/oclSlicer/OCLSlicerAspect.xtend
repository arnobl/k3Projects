package fr.inria.triskell.kompren.oclSlicer

import fr.inria.triskell.k3.Aspect
import fr.inria.triskell.k3.OverrideAspectMethod
import org.eclipse.ocl.ecore.AssociationClassCallExp
import org.eclipse.ocl.ecore.CallExp
import org.eclipse.ocl.ecore.CollectionItem
import org.eclipse.ocl.ecore.CollectionLiteralExp
import org.eclipse.ocl.ecore.CollectionLiteralPart
import org.eclipse.ocl.ecore.CollectionRange
import org.eclipse.ocl.ecore.ExpressionInOCL
import org.eclipse.ocl.ecore.FeatureCallExp
import org.eclipse.ocl.ecore.IfExp
import org.eclipse.ocl.ecore.IterateExp
import org.eclipse.ocl.ecore.IteratorExp
import org.eclipse.ocl.ecore.LetExp
import org.eclipse.ocl.ecore.LiteralExp
import org.eclipse.ocl.ecore.LoopExp
import org.eclipse.ocl.ecore.MessageExp
import org.eclipse.ocl.ecore.NavigationCallExp
import org.eclipse.ocl.ecore.OCLExpression
import org.eclipse.ocl.ecore.OperationCallExp
import org.eclipse.ocl.ecore.PropertyCallExp
import org.eclipse.ocl.ecore.StateExp
import org.eclipse.ocl.ecore.TupleLiteralExp
import org.eclipse.ocl.ecore.TupleLiteralPart
import org.eclipse.ocl.ecore.TypeExp
import org.eclipse.ocl.ecore.Variable
import org.eclipse.ocl.ecore.VariableExp
import org.eclipse.ocl.utilities.TypedElement
import org.eclipse.ocl.ecore.EnumLiteralExp
import org.eclipse.ocl.ecore.CallOperationAction
import org.eclipse.ocl.ecore.SendSignalAction
import org.eclipse.ocl.ecore.Constraint

@Aspect(className=typeof(Object))
abstract class SlicerVisitor {
	var boolean visitedPass = false
	var boolean visitedForRelations = false
	var boolean sliced = false

	def void visitToAddClasses(OCLSlicer theOCLSlicer) { visitedPass = true }

	def void visitToAddRelations(OCLSlicer theOCLSlicer) {}

	def boolean checkCanReallyBeAdded() {
		visitedPass = true
		return true
	}
}

@Aspect(className=typeof(AssociationClassCallExp))
class AssociationClassCallExpAspect extends NavigationCallExpAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		if(_self.referredAssociationClass!=null)
			_self.referredAssociationClass.visitToAddClasses(theOCLSlicer)
	}
}

@Aspect(className=typeof(ExpressionInOCL))
class ExpressionInOCLAspect extends SlicerVisitor {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		_self.bodyExpression.visitToAddClasses(theOCLSlicer)
		_self.contextVariable.visitToAddClasses(theOCLSlicer)
		if(_self.resultVariable!=null) _self.resultVariable.visitToAddClasses(theOCLSlicer)
		_self.parameterVariable.forEach[visitToAddClasses(theOCLSlicer)]
		theOCLSlicer.classifiers.addAll(_self.generatedType)
	}
}


@Aspect(className=typeof(OCLExpression))
abstract class OCLExpressionAspect extends TypedElementAspect {
}

@Aspect(className=typeof(TypedElement))
abstract class TypedElementAspect extends SlicerVisitor {
}

@Aspect(className=typeof(CallExp))
abstract class CallExpAspect extends OCLExpressionAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		if(_self.source!=null)
			_self.source.visitToAddClasses(theOCLSlicer)
	}
}

@Aspect(className=typeof(FeatureCallExp))
abstract class FeatureCallExpAspect extends CallExpAspect {
}

@Aspect(className=typeof(IfExp))
class IfExpAspect extends OCLExpressionAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		if(_self.condition!=null) _self.condition.visitToAddClasses(theOCLSlicer)
		if(_self.thenExpression!=null) _self.thenExpression.visitToAddClasses(theOCLSlicer)
		if(_self.elseExpression!=null) _self.elseExpression.visitToAddClasses(theOCLSlicer)
	}
}

@Aspect(className=typeof(IterateExp))
class IterateExpAspect extends LoopExpAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		if(_self.result!=null) _self.result.visitToAddClasses(theOCLSlicer)
	}
}

@Aspect(className=typeof(IteratorExp))
class IteratorExpAspect extends LoopExpAspect {
}

@Aspect(className=typeof(LetExp))
class LetExpAspect extends OCLExpressionAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		if(_self.in!=null) _self.in.visitToAddClasses(theOCLSlicer)
		if(_self.variable!=null) _self.variable.visitToAddClasses(theOCLSlicer)
	}
}

@Aspect(className=typeof(LiteralExp))
abstract class LiteralExpAspect extends OCLExpressionAspect {
}

@Aspect(className=typeof(CollectionItem))
class CollectionItemAspect extends CollectionLiteralPartAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		_self.item.visitToAddClasses(theOCLSlicer)
	}
}

@Aspect(className=typeof(CollectionLiteralPart))
abstract class CollectionLiteralPartAspect extends TypedElementAspect {
}

@Aspect(className=typeof(CollectionLiteralExp))
class CollectionLiteralExpAspect extends LiteralExpAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		_self.part.forEach[visitToAddClasses(theOCLSlicer)]
	}
}

@Aspect(className=typeof(CollectionRange))
class CollectionRangeAspect extends CollectionLiteralPartAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		_self.first.visitToAddClasses(theOCLSlicer)
		_self.last.visitToAddClasses(theOCLSlicer)
	}
}

@Aspect(className=typeof(EnumLiteralExp))
class EnumLiteralExpAspect extends LiteralExpAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		theOCLSlicer.enumLiterals.add(_self.referredEnumLiteral)
	}
}

@Aspect(className=typeof(LoopExp))
abstract class LoopExpAspect extends CallExpAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		if(_self.body!=null) _self.body.visitToAddClasses(theOCLSlicer)
		_self.iterator.forEach[visitToAddClasses(theOCLSlicer)]
	}
}

@Aspect(className=typeof(MessageExp))
class MessageExpAspect extends OCLExpressionAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		if(_self.target!=null) _self.target.visitToAddClasses(theOCLSlicer)
		_self.argument.forEach[visitToAddClasses(theOCLSlicer)]
		if(_self.calledOperation!=null) _self.calledOperation.visitToAddClasses(theOCLSlicer)
		_self.sentSignal
	}
}

@Aspect(className=typeof(SendSignalAction))
class SendSignalActionAspect extends SlicerVisitor {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		theOCLSlicer.classes.add(_self.class)
	}
}

@Aspect(className=typeof(CallOperationAction))
class CallOperationActionAspect extends SlicerVisitor {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		theOCLSlicer.ops.add(_self.operation)
	}
}

@Aspect(className=typeof(StateExp))
class StateExpAspect extends OCLExpressionAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		theOCLSlicer.objects.add(_self.referredState)
	}
}

@Aspect(className=typeof(TupleLiteralExp))
class TupleLiteralExpAspect extends LiteralExpAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		_self.part.forEach[visitToAddClasses(theOCLSlicer)]
	}
}

@Aspect(className=typeof(TypeExp))
class TypeExpAspect extends OCLExpressionAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		theOCLSlicer.classifiers.add(_self.referredType)
	}	
}

@Aspect(className=typeof(TupleLiteralPart))
class TupleLiteralPartAspect extends TypedElementAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		if(_self.value!=null) _self.value.visitToAddClasses(theOCLSlicer)
		theOCLSlicer.features.add(_self.attribute)
	}
}

@Aspect(className=typeof(OperationCallExp))
class OperationCallExpAspect extends FeatureCallExpAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		_self.argument.forEach[visitToAddClasses(theOCLSlicer)]
		theOCLSlicer.ops.add(_self.referredOperation)
	}
}

@Aspect(className=typeof(PropertyCallExp))
class PropertyCallExpAspect extends NavigationCallExpAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		theOCLSlicer.features.add(_self.referredProperty)
	}
}

@Aspect(className=typeof(NavigationCallExp))
abstract class NavigationCallExpAspect extends FeatureCallExpAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		if(_self.qualifier!=null)
			_self.qualifier.forEach[visitToAddClasses(theOCLSlicer)]
		if(_self.navigationSource!=null)
			theOCLSlicer.features.add(_self.navigationSource)
	}
}

@Aspect(className=typeof(Variable))
class VariableAspect extends TypedElementAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		if(_self.initExpression!=null) _self.initExpression.visitToAddClasses(theOCLSlicer)
		theOCLSlicer.params.add(_self.representedParameter)
	}
}

@Aspect(className=typeof(VariableExp))
class VariableExpAspect extends OCLExpressionAspect {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		if(_self.referredVariable!=null) _self.referredVariable.visitToAddClasses(theOCLSlicer)
	}
}

@Aspect(className=typeof(Constraint))
class ConstraintAspect extends SlicerVisitor {
	@OverrideAspectMethod
	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
		_self.super_visitToAddClasses(theOCLSlicer)
		_self.specification.visitToAddClasses(theOCLSlicer)
		theOCLSlicer.elts.addAll(_self.constrainedElements)
	}
}
