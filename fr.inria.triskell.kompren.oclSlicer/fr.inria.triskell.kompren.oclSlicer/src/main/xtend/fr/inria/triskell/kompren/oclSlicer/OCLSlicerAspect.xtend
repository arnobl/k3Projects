package fr.inria.triskell.kompren.oclSlicer

import fr.inria.triskell.k3.Aspect
import org.eclipse.ocl.ecore.AssociationClassCallExp
import org.eclipse.ocl.ecore.CallExp
import org.eclipse.ocl.ecore.CollectionItem
import org.eclipse.ocl.ecore.CollectionLiteralExp
import org.eclipse.ocl.ecore.CollectionLiteralPart
import org.eclipse.ocl.ecore.CollectionRange
import org.eclipse.ocl.ecore.Constraint
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

abstract class SlicerVisitor {
	var visitedPass = false

	var visitedForRelations = false

	var sliced = false


	def void visitToAddClasses(OCLSlicer theOCLSlicer) { visitedPass = true }

	def visitToAddRelations(OCLSlicer theOCLSlicer) {}

	def boolean checkCanReallyBeAdded() {
		visitedPass = true
		return true
	}
}

@Aspect(className=typeof(AssociationClassCallExp))
class AssociationClassCallExpAspect extends NavigationCallExpAspect {
	
}

@Aspect(className=typeof(ExpressionInOCL))
class ExpressionInOCLAspect extends SlicerVisitor {
}


@Aspect(className=typeof(OCLExpression))
abstract class OCLExpressionAspect extends TypedElementAspect {
	
}

@Aspect(className=typeof(TypedElement))
abstract class TypedElementAspect extends SlicerVisitor {
	
}

@Aspect(className=typeof(CallExp))
abstract class CallExpAspect extends OCLExpressionAspect {
	
}

@Aspect(className=typeof(FeatureCallExp))
abstract class FeatureCallExpAspect extends CallExpAspect {
	
}

@Aspect(className=typeof(IfExp))
class IfExpAspect extends OCLExpressionAspect {
	
}

@Aspect(className=typeof(IterateExp))
class IterateExpAspect extends LoopExpAspect {
	
}

@Aspect(className=typeof(IteratorExp))
class IteratorExpAspect extends LoopExpAspect {
	
}

@Aspect(className=typeof(LetExp))
class LetExpAspect extends OCLExpressionAspect {
	
}

@Aspect(className=typeof(LiteralExp))
class LiteralExpAspect extends OCLExpressionAspect {
	
}

@Aspect(className=typeof(CollectionItem))
class CollectionItemAspect extends CollectionLiteralPartAspect {
	
}

@Aspect(className=typeof(CollectionLiteralPart))
class CollectionLiteralPartAspect extends TypedElementAspect {
	
}

@Aspect(className=typeof(CollectionLiteralExp))
class CollectionLiteralExpAspect extends LiteralExpAspect {
	
}

@Aspect(className=typeof(CollectionRange))
class CollectionRangeAspect extends CollectionLiteralPartAspect {
	
}

@Aspect(className=typeof(LoopExp))
class LoopExpAspect extends CallExpAspect {
	
}

@Aspect(className=typeof(MessageExp))
class MessageExpAspect extends OCLExpressionAspect {
	
}

@Aspect(className=typeof(StateExp))
class StateExpAspect extends OCLExpressionAspect {
	
}

@Aspect(className=typeof(TupleLiteralExp))
class TupleLiteralExpAspect extends LiteralExpAspect {
	
}

@Aspect(className=typeof(TypeExp))
class TypeExpAspect extends OCLExpressionAspect {
	
}

@Aspect(className=typeof(TupleLiteralPart))
class TupleLiteralPartAspect extends TypedElementAspect {
	
}

@Aspect(className=typeof(OperationCallExp))
class OperationCallExpAspect extends FeatureCallExpAspect {
	
}

@Aspect(className=typeof(PropertyCallExp))
class PropertyCallExpAspect extends NavigationCallExpAspect {
	
}

@Aspect(className=typeof(NavigationCallExp))
abstract class NavigationCallExpAspect extends FeatureCallExpAspect {
	
}

@Aspect(className=typeof(Variable))
class VariableAspect extends TypedElementAspect {
	
}

@Aspect(className=typeof(VariableExp))
class VariableExpAspect extends OCLExpressionAspect {
	
}

@Aspect(className=typeof(Constraint))
class ConstraintAspect extends SlicerVisitor {
//	@OverrideAspectMethod
//	def void visitToAddClasses(OCLSlicer theOCLSlicer) {
//		if(!_self.visitedPass) {
//			super(theUnusedVarDetector)
//			_self.visitedPass = true
//			_self.statement.each{theExpression | theExpression.visitToAddClasses(theUnusedVarDetector)}
//		}
//	}
//	def visitToAddRelations(OCLSlicer theOCLSlicer) {
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.visitedForRelations := true
//			self.statement.each{theExpression | theExpression.visitToAddRelations(theUnusedVarDetector)}
//		end
//	}
}

//aspect class Expression inherits SlicerVisitor {
//}
//
//aspect class Conditional {
//	method visitToAddClasses(theUnusedVarDetector : UnusedVarDetector) is do
//		checkInitialisation()
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			if(not self.elseBody.isVoid) then self.elseBody.visitToAddClasses(theUnusedVarDetector) end
//			self.thenBody.visitToAddClasses(theUnusedVarDetector)
//		end
//	end
//	method visitToAddRelations(theUnusedVarDetector : UnusedVarDetector) is do
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.visitedForRelations := true
//			if(not self.elseBody.isVoid) then self.elseBody.visitToAddRelations(theUnusedVarDetector) end
//			self.thenBody.visitToAddRelations(theUnusedVarDetector)
//		end
//	end
//}
//
//aspect class Raise {
//	method visitToAddClasses(theUnusedVarDetector : UnusedVarDetector) is do
//		checkInitialisation()
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.expression.visitToAddClasses(theUnusedVarDetector)
//		end
//	end
//	method visitToAddRelations(theUnusedVarDetector : UnusedVarDetector) is do
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.visitedForRelations := true
//			self.expression.visitToAddRelations(theUnusedVarDetector)
//		end
//	end
//}
//
//aspect class Loop {
//	method visitToAddClasses(theUnusedVarDetector : UnusedVarDetector) is do
//		checkInitialisation()
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			if(not self.initialization.isVoid) then self.initialization.visitToAddClasses(theUnusedVarDetector) end
//			if(not self.body.isVoid) then self.body.visitToAddClasses(theUnusedVarDetector) end
//		end
//	end
//	method visitToAddRelations(theUnusedVarDetector : UnusedVarDetector) is do
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.visitedForRelations := true
//			if(not self.initialization.isVoid) then self.initialization.visitToAddRelations(theUnusedVarDetector) end
//			if(not self.body.isVoid) then self.body.visitToAddRelations(theUnusedVarDetector) end
//		end
//	end
//}
//
//aspect class LambdaExpression {
//	method visitToAddClasses(theUnusedVarDetector : UnusedVarDetector) is do
//		checkInitialisation()
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.body.visitToAddClasses(theUnusedVarDetector)
//		end
//	end
//	method visitToAddRelations(theUnusedVarDetector : UnusedVarDetector) is do
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.visitedForRelations := true
//			self.body.visitToAddRelations(theUnusedVarDetector)
//		end
//	end
//}
//
//aspect class Rescue inherits SlicerVisitor {
//	method visitToAddClasses(theUnusedVarDetector : UnusedVarDetector) is do
//		checkInitialisation()
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.body.each{theExpression | theExpression.visitToAddClasses(theUnusedVarDetector)}
//		end
//	end
//	method visitToAddRelations(theUnusedVarDetector : UnusedVarDetector) is do
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.visitedForRelations := true
//			self.body.each{theExpression | theExpression.visitToAddRelations(theUnusedVarDetector)}
//		end
//	end
//}
//
//aspect class CallExpression {
//	method visitToAddClasses(theUnusedVarDetector : UnusedVarDetector) is do
//		checkInitialisation()
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.parameters.each{theExpression | theExpression.visitToAddClasses(theUnusedVarDetector)}
//		end
//	end
//	method visitToAddRelations(theUnusedVarDetector : UnusedVarDetector) is do
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.visitedForRelations := true
//			self.parameters.each{theExpression | theExpression.visitToAddRelations(theUnusedVarDetector)}
//		end
//	end
//}
//
//aspect class Assignment {
//	method visitToAddClasses(theUnusedVarDetector : UnusedVarDetector) is do
//		checkInitialisation()
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.~value.visitToAddClasses(theUnusedVarDetector)
//		end
//	end
//	method visitToAddRelations(theUnusedVarDetector : UnusedVarDetector) is do
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.visitedForRelations := true
//			self.~value.visitToAddRelations(theUnusedVarDetector)
//		end
//	end
//}
//
//aspect class VariableDecl {
//	method visitToAddClasses(theUnusedVarDetector : UnusedVarDetector) is do
//		checkInitialisation()
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			if(not self.sliced) then
//				theUnusedVarDetector.addedVariableDecls.add(self)
//				self.sliced := true
//			end
//		end
//	end
//	method visitToAddRelations(theUnusedVarDetector : UnusedVarDetector) is do
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.visitedForRelations := true
//		end
//	end
//}
//
//aspect class CallVariable {
//	method visitToAddClasses(theUnusedVarDetector : UnusedVarDetector) is do
//		checkInitialisation()
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			if(not self.sliced) then
//				theUnusedVarDetector.addedCallVariables.add(self)
//				self.sliced := true
//			end
//		end
//	end
//	method visitToAddRelations(theUnusedVarDetector : UnusedVarDetector) is do
//		if(not self.visitedPass) then
//			super(theUnusedVarDetector)
//			self.visitedPass := true
//			self.visitedForRelations := true
//		end
//	end
//}

